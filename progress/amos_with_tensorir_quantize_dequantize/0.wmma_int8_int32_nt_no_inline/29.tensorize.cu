#[version = "0.0.5"]
@main = primfn(a: handle, b: handle, c: handle) -> ()
  attr = {"tir.noalias": True, "global_symbol": "main"}
  buffers = {A: Buffer(A_1: Pointer(global int8), int8, [16384, 16384], []),
             B: Buffer(B_1: Pointer(global int8), int8, [16384, 16384], []),
             C: Buffer(C_1: Pointer(global int8), int8, [16384, 16384], [])}
  buffer_map = {a: A, b: B, c: C} {
  block([], "root") {
    tir.reads([])
    tir.writes([])
    QA = alloc_buffer(int8[16384, 16384])
    QB = alloc_buffer(int8[16384, 16384])
    QC = alloc_buffer(int32[16384, 16384])
    A_global = alloc_buffer(int8[1024, 1024, 16, 16])
    QA_shared = alloc_buffer(int8[1024, 1024, 16, 16])
    QA_shared_wmma.matrix_a = alloc_buffer(int8[1024, 1024, 16, 16])
    B_global = alloc_buffer(int8[1024, 1024, 16, 16])
    QB_shared = alloc_buffer(int8[1024, 1024, 16, 16])
    QB_shared_wmma.matrix_b = alloc_buffer(int8[1024, 1024, 16, 16])
    QC_wmma.accumulator = alloc_buffer(int32[1024, 1024, 16, 16])
     {
      for (ax0: int32, 0, 16384) {
        for (ax1: int32, 0, 16384) {
          block([16384, 16384], "B_global") as [v0, v1] {
            bind(v0, ax0)
            bind(v1, ax1)
            tir.reads([B[v0, v1]])
            tir.writes([B_global[floordiv(v0, 16), floordiv(v1, 16), floormod(v0, 16), floormod(v1, 16)]])
            B_global[floordiv(v0, 16), floordiv(v1, 16), floormod(v0, 16), floormod(v1, 16)] = B[v0, v1]
        }
      }
      for (ax0_1: int32, 0, 16384) {
        for (ax1_1: int32, 0, 16384) {
          block([16384, 16384], "A_global") as [v0_1, v1_1] {
            bind(v0_1, ax0_1)
            bind(v1_1, ax1_1)
            tir.reads([A[v0_1, v1_1]])
            tir.writes([A_global[floordiv(v0_1, 16), floordiv(v1_1, 16), floormod(v0_1, 16), floormod(v1_1, 16)]])
            A_global[floordiv(v0_1, 16), floordiv(v1_1, 16), floormod(v0_1, 16), floormod(v1_1, 16)] = A[v0_1, v1_1]
        }
      }
      for (i_0_0: int32, 0, 64) "thread_binding" {
        for (j_0_0_0: int32, 0, 8) "thread_binding" {
          for (j_0_0_1: int32, 0, 32) "thread_binding" {
            for (i_0_1: int32, 0, 4) "thread_binding" {
              for (j_0_1: int32, 0, 1) "thread_binding" {
                for (ax0_2: int32, 0, 256) {
                  for (ax1_2: int32, 0, 16384) {
                    block([16384, 16384], "Quantize_A") as [vi, vj] {
                      bind(vi, ((i_0_0*256) + ax0_2))
                      bind(vj, ax1_2)
                      tir.reads([A_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)]])
                      tir.writes([QA[vi, vj]])
                      QA[vi, vj] = cast(int8, (@tir.round((cast(float32, A_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)])*0.5f32), dtype=float32) - 0f32))
                  }
                }
                for (ax0_3: int32, 0, 64) {
                  for (ax1_3: int32, 0, 16384) {
                    block([16384, 16384], "Quantize_B") as [vi_1, vj_1] {
                      bind(vi_1, (((j_0_0_0*2048) + (j_0_0_1*64)) + ax0_3))
                      bind(vj_1, ax1_3)
                      tir.reads([B_global[floordiv(vi_1, 16), floordiv(vj_1, 16), floormod(vi_1, 16), floormod(vj_1, 16)]])
                      tir.writes([QB[vi_1, vj_1]])
                      QB[vi_1, vj_1] = cast(int8, (@tir.round((cast(float32, B_global[floordiv(vi_1, 16), floordiv(vj_1, 16), floormod(vi_1, 16), floormod(vj_1, 16)])*0.1f32), dtype=float32) - 0f32))
                  }
                }
                for (i_0_2_init: int32, 0, 4) {
                  for (j_0_2_init: int32, 0, 4) {
                    block([1024, 1024], "B_init_o") as [vi_o, vj_o] {
                      bind(vi_o, (((i_0_0*16) + (i_0_1*4)) + i_0_2_init))
                      bind(vj_o, ((((j_0_0_0*128) + (j_0_0_1*4)) + (j_0_1*4)) + j_0_2_init))
                      tir.reads([])
                      tir.writes([QC_wmma.accumulator[vi_o, vj_o, 0:16, 0:16]])
                      C_2 = match_buffer(QC_wmma.accumulator[vi_o, vj_o, 0:16, 0:16])
                      @tir.tvm_fill_fragment(C_3: Pointer(wmma.accumulator int32), 16, 16, 16, ((floordiv(floordiv(elem_offset: int32, C_s0: int32), 16)*floordiv(C_s0, 16)) + floordiv(floormod(elem_offset, C_s0), 16)), 0f32, dtype=handle)
                  }
                }
                for (k_0_0: int32, 0, 256) {
                  for (ax0_0_ax1_0_ax0_1_ax1_1_fused_0: int32, 0, 4) "thread_binding" {
                    for (ax0_0_ax1_0_ax0_1_ax1_1_fused_1: int32, 0, 1) "thread_binding" {
                      for (ax0_0_ax1_0_ax0_1_ax1_1_fused_2: int32, 0, 8) {
                        for (ax0_0_ax1_0_ax0_1_ax1_1_fused_3: int32, 0, 32) "thread_binding" {
                          for (ax0_0_ax1_0_ax0_1_ax1_1_fused_4: int32, 0, 16) "vectorized" {
                            block([16384, 16384], "QA_shared") as [v0_2, v1_2] {
                              bind(v0_2, (((i_0_0*256) + (floordiv((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0*4096) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1*4096)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4), 1024)*16)) + floordiv(floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0*4096) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1*4096)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4), 256), 16)))
                              bind(v1_2, (((k_0_0*64) + (floordiv(floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0*4096) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1*4096)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4), 1024), 256)*16)) + floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0*4096) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1*4096)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4), 16)))
                              tir.reads([QA[v0_2, v1_2]])
                              tir.writes([QA_shared[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)]])
                              QA_shared[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)] = QA[v0_2, v1_2]
                          }
                        }
                      }
                    }
                  }
                  for (ax0_0_ax1_0_ax0_1_ax1_1_fused_0_1: int32, 0, 4) "thread_binding" {
                    for (ax0_0_ax1_0_ax0_1_ax1_1_fused_1_1: int32, 0, 1) "thread_binding" {
                      for (ax0_0_ax1_0_ax0_1_ax1_1_fused_2_1: int32, 0, 2) {
                        for (ax0_0_ax1_0_ax0_1_ax1_1_fused_3_1: int32, 0, 32) "thread_binding" {
                          for (ax0_0_ax1_0_ax0_1_ax1_1_fused_4_1: int32, 0, 16) "vectorized" {
                            block([16384, 16384], "QB_shared") as [v0_3, v1_3] {
                              bind(v0_3, ((((j_0_0_0*2048) + (j_0_0_1*64)) + (floordiv((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0_1*1024) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1_1*1024)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2_1*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3_1*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4_1), 1024)*16)) + floordiv(floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0_1*1024) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1_1*1024)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2_1*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3_1*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4_1), 256), 16)))
                              bind(v1_3, (((k_0_0*64) + (floordiv(floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0_1*1024) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1_1*1024)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2_1*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3_1*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4_1), 1024), 256)*16)) + floormod((((((ax0_0_ax1_0_ax0_1_ax1_1_fused_0_1*1024) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_1_1*1024)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_2_1*512)) + (ax0_0_ax1_0_ax0_1_ax1_1_fused_3_1*16)) + ax0_0_ax1_0_ax0_1_ax1_1_fused_4_1), 16)))
                              tir.reads([QB[v0_3, v1_3]])
                              tir.writes([QB_shared[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)]])
                              QB_shared[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)] = QB[v0_3, v1_3]
                          }
                        }
                      }
                    }
                  }
                  for (k_0_1: int32, 0, 4) {
                    for (ax0_0: int32, 0, 4) {
                      for (ax1_0: int32, 0, 1) {
                        block([1024, 1024], "QA_shared_wmma.matrix_a_o") as [v0_o, v1_o] {
                          bind(v0_o, (((i_0_0*16) + (i_0_1*4)) + ax0_0))
                          bind(v1_o, (((k_0_0*4) + k_0_1) + ax1_0))
                          tir.reads([QA_shared[v0_o, v1_o, 0:16, 0:16]])
                          tir.writes([QA_shared_wmma.matrix_a[v0_o, v1_o, 0:16, 0:16]])
                          A_2 = match_buffer(QA_shared[v0_o, v1_o, 0:16, 0:16])
                          C_4 = match_buffer(QA_shared_wmma.matrix_a[v0_o, v1_o, 0:16, 0:16])
                          @tir.tvm_load_matrix_sync(C_5: Pointer(wmma.matrix_a int8), 16, 16, 16, ((floordiv(floordiv(elem_offset_1: int32, C_s0_1: int32), 16)*floordiv(C_s0_1, 16)) + floordiv(floormod(elem_offset_1, C_s0_1), 16)), @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int8), A_3: Pointer(shared int8), elem_offset_2: int32, (A_s0: int32*16), 1, dtype=handle), A_s0, "row_major", dtype=handle)
                      }
                    }
                    for (ax0_0_1: int32, 0, 4) {
                      for (ax1_0_1: int32, 0, 1) {
                        block([1024, 1024], "QB_shared_wmma.matrix_b_o") as [v0_o_1, v1_o_1] {
                          bind(v0_o_1, (((j_0_0_0*128) + (j_0_0_1*4)) + ax0_0_1))
                          bind(v1_o_1, (((k_0_0*4) + k_0_1) + ax1_0_1))
                          tir.reads([QB_shared[v0_o_1, v1_o_1, 0:16, 0:16]])
                          tir.writes([QB_shared_wmma.matrix_b[v0_o_1, v1_o_1, 0:16, 0:16]])
                          A_4 = match_buffer(QB_shared[v0_o_1, v1_o_1, 0:16, 0:16])
                          C_6 = match_buffer(QB_shared_wmma.matrix_b[v0_o_1, v1_o_1, 0:16, 0:16])
                          @tir.tvm_load_matrix_sync(C_7: Pointer(wmma.matrix_b int8), 16, 16, 16, ((floordiv(floordiv(elem_offset_3: int32, C_s0_2: int32), 16)*floordiv(C_s0_2, 16)) + floordiv(floormod(elem_offset_3, C_s0_2), 16)), @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int8), A_5: Pointer(shared int8), elem_offset_4: int32, (A_s0_1: int32*16), 1, dtype=handle), A_s0_1, "col_major", dtype=handle)
                      }
                    }
                    for (i_0_2: int32, 0, 4) {
                      for (j_0_2: int32, 0, 4) {
                        block([1024, 1024, tir.reduce_axis(0, 1024)], "B_update_o") as [vi_o_1, vj_o_1, vk_o] {
                          bind(vi_o_1, (((i_0_0*16) + (i_0_1*4)) + i_0_2))
                          bind(vj_o_1, ((((j_0_0_0*128) + (j_0_0_1*4)) + (j_0_1*4)) + j_0_2))
                          bind(vk_o, ((k_0_0*4) + k_0_1))
                          tir.reads([QC_wmma.accumulator[vi_o_1, vj_o_1, 0:16, 0:16], QA_shared_wmma.matrix_a[vi_o_1, vk_o, 0:16, 0:16], QB_shared_wmma.matrix_b[vj_o_1, vk_o, 0:16, 0:16]])
                          tir.writes([QC_wmma.accumulator[vi_o_1, vj_o_1, 0:16, 0:16]])
                          A_6 = match_buffer(QA_shared_wmma.matrix_a[vi_o_1, vk_o, 0:16, 0:16])
                          B_2 = match_buffer(QB_shared_wmma.matrix_b[vj_o_1, vk_o, 0:16, 0:16])
                          C_8 = match_buffer(QC_wmma.accumulator[vi_o_1, vj_o_1, 0:16, 0:16])
                          @tir.tvm_mma_sync(C_9: Pointer(wmma.accumulator int32), ((floordiv(floordiv(elem_offset_5: int32, C_s0_3: int32), 16)*floordiv(C_s0_3, 16)) + floordiv(floormod(elem_offset_5, C_s0_3), 16)), A_7: Pointer(wmma.matrix_a int8), ((floordiv(floordiv(elem_offset_6: int32, A_s0_2: int32), 16)*floordiv(A_s0_2, 16)) + floordiv(floormod(elem_offset_6, A_s0_2), 16)), B_3: Pointer(wmma.matrix_b int8), ((floordiv(floordiv(elem_offset_7: int32, B_s0: int32), 16)*floordiv(B_s0, 16)) + floordiv(floormod(elem_offset_7, B_s0), 16)), C_9, ((floordiv(floordiv(elem_offset_5, C_s0_3), 16)*floordiv(C_s0_3, 16)) + floordiv(floormod(elem_offset_5, C_s0_3), 16)), dtype=handle)
                      }
                    }
                  }
                }
                for (ax0_0_2: int32, 0, 4) {
                  for (ax1_0_2: int32, 0, 4) {
                    block([1024, 1024], "QC_wmma.accumulator_o") as [v0_o_2, v1_o_2] {
                      bind(v0_o_2, (((i_0_0*16) + (i_0_1*4)) + ax0_0_2))
                      bind(v1_o_2, (((j_0_0_0*128) + (j_0_0_1*4)) + ax1_0_2))
                      tir.reads([QC_wmma.accumulator[v0_o_2, v1_o_2, 0:16, 0:16]])
                      tir.writes([QC[(v0_o_2*16):((v0_o_2*16) + 16), (v1_o_2*16):((v1_o_2*16) + 16)]])
                      A_8 = match_buffer(QC_wmma.accumulator[v0_o_2, v1_o_2, 0:16, 0:16])
                      C_10 = match_buffer(QC[(v0_o_2*16):((v0_o_2*16) + 16), (v1_o_2*16):((v1_o_2*16) + 16)])
                      @tir.tvm_store_matrix_sync(A_9: Pointer(wmma.accumulator int32), 16, 16, 16, ((floordiv(floordiv(elem_offset_8: int32, A_s0_3: int32), 16)*floordiv(A_s0_3, 16)) + floordiv(floormod(elem_offset_8, A_s0_3), 16)), @tir.tvm_access_ptr(@tir.type_annotation(, dtype=int32), C_11: Pointer(global int32), elem_offset_9: int32, (C_s0_4: int32*16), 2, dtype=handle), C_s0_4, "row_major", dtype=handle)
                  }
                }
                for (ax0_4: int32, 0, 64) {
                  for (ax1_4: int32, 0, 64) {
                    block([16384, 16384], "DeQuantize_C") as [vi_2, vj_2] {
                      bind(vi_2, (((i_0_0*256) + (i_0_1*64)) + ax0_4))
                      bind(vj_2, (((j_0_0_0*2048) + (j_0_0_1*64)) + ax1_4))
                      tir.reads([QC[vi_2, vj_2]])
                      tir.writes([C[vi_2, vj_2]])
                      C[vi_2, vj_2] = cast(int8, ((cast(float32, QC[vi_2, vj_2]) / 0.01f32) + 0f32))
                  }
                }
              }
            }
          }
        }
      }
    }
}

#[metadata]
{
  "root": 1, 
  "nodes": [
    {
      "type_key": ""
    }, 
    {
      "type_key": "Map", 
      "keys": [
        "IntImm"
      ], 
      "data": [2]
    }, 
    {
      "type_key": "Array", 
      "data": [3]
    }, 
    {
      "type_key": "IntImm", 
      "attrs": {
        "dtype": "bool", 
        "span": "0", 
        "value": "1"
      }
    }
  ], 
  "b64ndarrays": [], 
  "attrs": {"tvm_version": "0.11.dev0"}
}