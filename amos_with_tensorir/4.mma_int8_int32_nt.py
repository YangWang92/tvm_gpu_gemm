'''
Problem definition:
    the mma version of tricky tensorize
    Consider the following matrix multiplication:
        C = A * B
    where A, B, C are all 2D tensors.
    A is of shape [M, K, 16, 32]
    B is of shape [N, K, 16, 32]
    C is of shape [M, N, 16, 16]
    The tricky part is that the innermost dimension of A and B are contiguous.
    We consider a single kernel of  BM=128, BN=128, BK=64
'''
import tvm
from tvm import te
import numpy as np
import tvm.testing
from tvm.script import tir as T
import os
from intrin.tricky_mma_int8_int32 import (
    TRICKY_MMA_fill_16x16_i32_INTRIN,
    TRICKY_LDMATRIX_16x32_A_INTRIN,
    TRICKY_LDMATRIX_32x16_B_INTRIN,
    TRICKY_LDMATRIX_16x32_B_TRANS_INTRIN,
    TRICKY_MMA_i8i8i32_INTRIN,
    TRICKY_MMA_i8i8i32_TRANS_INTRIN,
    TRICKY_MMA_store_16x16_i32_global_INTRIN,
    TRICKY_MMA_A_G2S_16x32_i8_INTRIN,
    TRICKY_MMA_B_TRANS_G2S_16x32_i8_INTRIN,
    shared_16x16_to_ldmatrix_32x8_layout,
    shared_32x16_to_ldmatrix_32x16_layout,
    shared_16x32_to_ldmatrix_32x16_layout,
    shared_16x32_to_ldmatrix_32x16_permutation,
    A_global_16x32_to_shared_load_16x32_layout,
    B_global_16x32_to_shared_load_16x32_layout,
)

log_path = "progress/amos_with_tensorir/4.mma_int8_int32_nt"
count = 0


def write_code(code, path, fname):
    global count
    # if path not exist, create it
    fname = str(count) + "." + fname
    count += 1
    if not os.path.exists(path):
        os.makedirs(path)
    # join path and fname
    fname = os.path.join(path, fname)
    with open(fname, "w") as f:
        f.write(code)


def write_sch(sch, path, fname):
    py_fname = fname + ".py"
    write_code(sch.mod["main"].script(), path, py_fname)
    cu_fname = fname + ".cu"
    write_code(sch.mod.astext(), path, cu_fname)


VERIFY = True

M = 16384
N = 16384
K = 16384
if VERIFY:
    M = 256
    N = 256
    K = 256

warp_size = 32
block_row_warps = 4
block_col_warps = 1
warp_row_tiles = 4
warp_col_tiles = 4
chunk = 2
splitk = 16
vec = 16
wmma_m = 16
wmma_n = 16
wmma_k = 32

@tvm.script.ir_module
class MyModule:
    @T.prim_func
    def main(a: T.handle, b: T.handle, c: T.handle):
        T.func_attr({"global_symbol": "main", "tir.noalias": True})
        A = T.match_buffer(a, [M, K], dtype="int8")
        B = T.match_buffer(b, [N, K], dtype="int8")
        C = T.match_buffer(c, [M, N], dtype="int32")

        for i, j, k  in T.grid(M, N, K):
            with T.block("B"):
                vi, vj, vk = T.axis.remap("SSR", [i, j, k])
                with T.init():
                    C[vi, vj] = 0
                C[vi, vj] = C[vi, vj] + \
                    A[vi, vk].astype("int32") * B[vj, vk].astype("int32")


ir_module = MyModule
sch = tvm.tir.Schedule(ir_module, debug_mask="all")

print(type(ir_module))
print(ir_module.script())

write_sch(sch, log_path, "original")

block_b = sch.get_block("B")
block_tricky_A = sch.cache_read(block_b, 0, "global")
block_tricky_shared_A = sch.cache_read(block_b, 0, "shared")
block_tricky_shared_local_A = sch.cache_read(block_b, 0, "warp")
block_tricky_B = sch.cache_read(block_b, 1, "global")
block_tricky_shared_B = sch.cache_read(block_b, 1, "shared")
block_tricky_shared_local_B = sch.cache_read(block_b, 1, "warp")
# block_tricky_C = sch.cache_write(block_b, 0, "global")
block_tricky_local_C = sch.cache_write(block_b, 0, "warp")

write_sch(sch, log_path, "cache_related")
def tricky_transform_A(i, j):
    return (i // wmma_m, j // wmma_k, i % wmma_m, j % wmma_k)


def tricky_transform_B(i, j):
    return (i // wmma_n, j // wmma_k, i % wmma_n, j % wmma_k)


def tricky_transform_C(i, j):
    return (i // wmma_m, j // wmma_n, i % wmma_m, j % wmma_n)

sch.transform_layout(block_tricky_A, ("write", 0),tricky_transform_A)
sch.transform_layout(block_tricky_B, ("write", 0),tricky_transform_B)
sch.transform_layout(block_tricky_shared_A, ("write", 0), tricky_transform_A)
sch.transform_layout(block_tricky_shared_B, ("write", 0), tricky_transform_B)
sch.transform_layout(block_tricky_shared_local_A, ("write", 0), tricky_transform_A)
sch.transform_layout(block_tricky_shared_local_B, ("write", 0), tricky_transform_B)
sch.transform_layout(block_b, ("write", 0), tricky_transform_C)
sch.transform_layout(block_tricky_local_C, ("write", 0),tricky_transform_C)

write_sch(sch, log_path, "tricky_transform")

(i, j, k) = sch.get_loops(block_b)
i, kernel_i = sch.split(i, factors=[None, wmma_m])
j, kernel_j = sch.split(j, factors=[None, wmma_n])
k, kernel_k = sch.split(k, factors=[None, wmma_k])
sch.reorder(i, j, k, kernel_i, kernel_j, kernel_k)

write_sch(sch, log_path, "tricky_extract_compute")

block_i, i, ii = sch.split(i, factors=[None, block_row_warps, warp_row_tiles])
block_j, j, jj = sch.split(j, factors=[None, block_col_warps, warp_col_tiles])
ko, ki = sch.split(k, factors=[None, chunk])
sch.reorder(block_i, block_j, i, j, ko, ki, ii, jj, kernel_i, kernel_j, kernel_k)

write_sch(sch, log_path, "block_tile")

sch.bind(block_i, "blockIdx.x")
sch.bind(block_j, "blockIdx.y")
sch.bind(i, "threadIdx.y")
sch.bind(j, "threadIdx.z")
sch.annotate(ko, ann_key="thread_rasterization", ann_val=splitk)

write_sch(sch, log_path, "thread_bind")


# cache read A from global memory to shared_memory
sch.compute_at(block_tricky_shared_local_A, ki)
sch.compute_at(block_tricky_shared_A, ko)
sch.compute_at(block_tricky_shared_local_B, ki)
sch.compute_at(block_tricky_shared_B, ko)
sch.reverse_compute_at(block_tricky_local_C, j)
write_sch(sch, log_path, "cache_read_compute_at")

def tricky_extract_cache(block, sub_i, sub_j):
    i, j = sch.get_loops(block)[-2:]
    i, kernel_i = sch.split(i, factors=[None, sub_i])
    j, kernel_j = sch.split(j, factors=[None, sub_j])
    sch.reorder(i, j, kernel_i, kernel_j)
    return (i, j, kernel_i, kernel_j)


block_tricky_shared_local_A_loops = tricky_extract_cache(
    block_tricky_shared_local_A, wmma_m, wmma_k)
block_tricky_shared_A_loops = tricky_extract_cache(
    block_tricky_shared_A, wmma_m, wmma_k)
block_tricky_shared_local_B_loops = tricky_extract_cache(
    block_tricky_shared_local_B, wmma_n, wmma_k)
block_tricky_shared_B_loops = tricky_extract_cache(
    block_tricky_shared_B, wmma_n, wmma_k)
block_tricky_local_C_loops = tricky_extract_cache(
    block_tricky_local_C, wmma_m, wmma_n)

write_sch(sch, log_path, "tricky_extract_cache")

# 128x32

sch.tensorize(sch.get_loops(block_tricky_shared_A)[-2], TRICKY_MMA_A_G2S_16x32_i8_INTRIN)
block_tricky_shared_A = sch.get_block("A_g2s_shared")
sch.tensorize(sch.get_loops(block_tricky_shared_B)[-2], TRICKY_MMA_B_TRANS_G2S_16x32_i8_INTRIN)
block_tricky_shared_B = sch.get_block("B_g2s_shared_trans")

write_sch(sch, log_path, "transform_layout")

A_shared_fused = sch.fuse(*sch.get_loops(block_tricky_shared_A)[-4:])
A_shared_ty, A_shared_tz, A_shared_inner, A_shared_tx, A_shared_vi = sch.split(
    A_shared_fused, factors=[block_row_warps, block_col_warps, None, warp_size, vec])
sch.vectorize(A_shared_vi)
sch.bind(A_shared_tx, "threadIdx.x")
sch.bind(A_shared_ty, "threadIdx.y")
sch.bind(A_shared_tz, "threadIdx.z")
write_sch(sch, log_path, "schedule_A_shared")

B_shared_fused = sch.fuse(*sch.get_loops(block_tricky_shared_B)[-4:])
B_shared_ty, B_shared_tz, B_shared_inner, B_shared_tx, B_shared_vi = sch.split(
    B_shared_fused, factors=[block_row_warps, block_col_warps, None, warp_size, vec])
sch.vectorize(B_shared_vi)
sch.bind(B_shared_tx, "threadIdx.x")
sch.bind(B_shared_ty, "threadIdx.y")
sch.bind(B_shared_tz, "threadIdx.z")
write_sch(sch, log_path, "schedule_B_shared")


# decompose reduction
init_block_b = sch.decompose_reduction(block_b, ko)
write_sch(sch, log_path, "decompose_reduction")

# transform layout

def index_map_A(i, k, wmma_m, wmma_k):
    return (i, k, *shared_16x32_to_ldmatrix_32x16_layout(wmma_m, wmma_k), )

def index_map_B(j, k, wmma_n, wmma_k):
    return (j, k, *shared_16x32_to_ldmatrix_32x16_layout(wmma_n, wmma_k), )

def index_map_C(i, j, wmma_m, wmma_n):
    return (i, j, *shared_16x16_to_ldmatrix_32x8_layout(wmma_m, wmma_n), )




sch.transform_layout(block_tricky_shared_local_A, ("write", 0), index_map_A)
sch.transform_layout(block_tricky_shared_local_B, ("write", 0), index_map_A)
sch.transform_layout(block_tricky_local_C, ("read", 0), index_map_C)
write_sch(sch, log_path, "transform_layout")

init_block_b_i, init_block_b_j = sch.get_loops(init_block_b)[-4:-2]
sch.tensorize(sch.get_loops(init_block_b)[-2], TRICKY_MMA_fill_16x16_i32_INTRIN)
write_sch(sch, log_path,
          "tensorize_fill")
block_shared_local_A_i, block_shared_local_A_j = sch.get_loops(block_tricky_shared_local_A)[-4:-2]
sch.tensorize(sch.get_loops(block_tricky_shared_local_A)
              [-2], TRICKY_LDMATRIX_16x32_A_INTRIN)
write_sch(sch, log_path,
          "tensorize_load")
block_shared_local_B_i, block_shared_local_B_j = sch.get_loops(block_tricky_shared_local_B)[-4:-2]
sch.tensorize(sch.get_loops(block_tricky_shared_local_B)
              [-2], TRICKY_LDMATRIX_16x32_B_TRANS_INTRIN)
sch.tensorize(kernel_i, TRICKY_MMA_i8i8i32_TRANS_INTRIN)

sch.tensorize(sch.get_loops(block_tricky_local_C)[-2], TRICKY_MMA_store_16x16_i32_global_INTRIN)
write_sch(sch, log_path,
           "tensorize")

# schdule tricky transform

def schedule_tricky_transform(block, vec):
    i, j = sch.get_loops(block)[-2:]
    if K <= 16384:
        fused_axis = sch.fuse(i, j)
        # 16384
        by, bx, vx, ty, tx, fused_inner, fused_vi = sch.split(
            fused_axis, factors=[8192, 32, 1, 1, 8, None, vec])
        # 8192
        # by, bx, vx, ty, tx, fused_inner, fused_vi = sch.split(
        #     fused_axis, factors=[256, 256, 4, 2, 8, None, vec])
        
        sch.vectorize(fused_vi)
        sch.bind(by, "blockIdx.y")
        sch.bind(bx, "blockIdx.x")
        sch.bind(vx, "vthread.x")
        sch.bind(ty, "threadIdx.y")
        sch.bind(tx, "threadIdx.x")
        # sch.unroll(fused_inner)
    else:
        bx, fused_inner, ty, tx, fused_vi = sch.split(
            j, factors=[1024, None, 32, 32, vec])
        sch.vectorize(fused_vi)
        sch.bind(bx, "blockIdx.x")
        sch.bind(ty, "threadIdx.y")
        sch.bind(tx, "threadIdx.x")

schedule_tricky_transform(block_tricky_A, vec=vec)
schedule_tricky_transform(block_tricky_B, vec=vec)
# unroll
# sch.unroll(init_block_b_i)
# sch.unroll(init_block_b_j)
# sch.unroll(block_shared_local_A_i)
# sch.unroll(block_shared_local_A_j)
# sch.unroll(block_shared_local_B_i)
# sch.unroll(block_shared_local_B_j)
# sch.unroll(ii)
# sch.unroll(jj)
# sch.unroll(A_shared_inner)
# sch.unroll(B_shared_inner)


write_sch(sch, log_path,
           "do_unroll")


ctx = tvm.cuda(0)
cuda_mod = tvm.build(sch.mod, target="cuda")

write_code(cuda_mod.imported_modules[0].get_source(), log_path, "tmp.cu")

a_np = (np.random.rand(
    M, K) * 4).astype("int8")
b_np = (np.random.rand(
    N, K) * 4).astype("int8")

cuda_a = tvm.nd.array((a_np).astype("int8"), ctx)
cuda_b = tvm.nd.array((b_np).astype("int8"), ctx)
cuda_c = tvm.nd.array(
    np.zeros((M // wmma_m, N // wmma_n, wmma_m, wmma_n)).astype("int32"), ctx)


if VERIFY:
    cuda_mod(cuda_a, cuda_b, cuda_c)
    # c_np = cuda_c.numpy()
    c_np = cuda_c.numpy().transpose((0, 2, 1, 3)).reshape(M, N)
    np_c = np.matmul(a_np.astype("int32"), b_np.astype("int32").T)
    print("np result: ", np_c[0][0:10])
    print("tvm result: ", c_np[0][0:10])
    np.testing.assert_allclose(
        c_np, np_c, rtol=1e-3, atol=1e-3
    )
    print("assert_allclose pass!")

num_flops = 2 * M * K * N
num_runs = 3
timer_cuda_mod = cuda_mod.time_evaluator(
    cuda_mod.entry_name, ctx, number=num_runs)

t = timer_cuda_mod(cuda_a, cuda_b, cuda_c).mean

GFLOPS = num_flops / (t * 1e3) / 1e6
print("average time cost of %d runs = %g ms, %g GFLOPS." %
      (num_runs, t * 1e3, GFLOPS))
