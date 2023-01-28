#[version = "0.0.5"]
@main = primfn(a: handle, b: handle, c: handle) -> ()
  attr = {"tir.noalias": True, "global_symbol": "main"}
  buffers = {A: Buffer(A_1: Pointer(global int8), int8, [16384, 16384], []),
             B: Buffer(B_1: Pointer(global int8), int8, [16384, 16384], []),
             C: Buffer(C_1: Pointer(global int32), int32, [16384, 16384], [])}
  buffer_map = {a: A, b: B, c: C} {
  block([], "root") {
    tir.reads([])
    tir.writes([])
    A_global = alloc_buffer(int8[1024, 1024, 16, 16])
    A_global_shared = alloc_buffer(int8[1024, 1024, 16, 16])
    B_global = alloc_buffer(int8[1024, 1024, 16, 16])
    B_global_shared = alloc_buffer(int8[1024, 1024, 16, 16])
    C_global = alloc_buffer(int32[1024, 1024, 16, 16])
     {
      for (ax0_0: int32, 0, 1024) {
        for (ax1_0: int32, 0, 1024) {
          for (ax0_1: int32, 0, 16) {
            for (ax1_1: int32, 0, 16) {
              block([16384, 16384], "B_global") as [v0, v1] {
                bind(v0, ((ax0_0*16) + ax0_1))
                bind(v1, ((ax1_0*16) + ax1_1))
                tir.reads([B[v0, v1]])
                tir.writes([B_global[floordiv(v0, 16), floordiv(v1, 16), floormod(v0, 16), floormod(v1, 16)]])
                B_global[floordiv(v0, 16), floordiv(v1, 16), floormod(v0, 16), floormod(v1, 16)] = B[v0, v1]
            }
          }
        }
      }
      for (ax0_0_1: int32, 0, 1024) {
        for (ax1_0_1: int32, 0, 1024) {
          for (ax0_1_1: int32, 0, 16) {
            for (ax1_1_1: int32, 0, 16) {
              block([16384, 16384], "A_global") as [v0_1, v1_1] {
                bind(v0_1, ((ax0_0_1*16) + ax0_1_1))
                bind(v1_1, ((ax1_0_1*16) + ax1_1_1))
                tir.reads([A[v0_1, v1_1]])
                tir.writes([A_global[floordiv(v0_1, 16), floordiv(v1_1, 16), floormod(v0_1, 16), floormod(v1_1, 16)]])
                A_global[floordiv(v0_1, 16), floordiv(v1_1, 16), floormod(v0_1, 16), floormod(v1_1, 16)] = A[v0_1, v1_1]
            }
          }
        }
      }
      for (ax0: int32, 0, 16384) {
        for (ax1: int32, 0, 16384) {
          block([16384, 16384], "A_global_shared") as [v0_2, v1_2] {
            bind(v0_2, ax0)
            bind(v1_2, ax1)
            tir.reads([A_global[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)]])
            tir.writes([A_global_shared[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)]])
            A_global_shared[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)] = A_global[floordiv(v0_2, 16), floordiv(v1_2, 16), floormod(v0_2, 16), floormod(v1_2, 16)]
        }
      }
      for (ax0_2: int32, 0, 16384) {
        for (ax1_2: int32, 0, 16384) {
          block([16384, 16384], "B_global_shared") as [v0_3, v1_3] {
            bind(v0_3, ax0_2)
            bind(v1_3, ax1_2)
            tir.reads([B_global[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)]])
            tir.writes([B_global_shared[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)]])
            B_global_shared[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)] = B_global[floordiv(v0_3, 16), floordiv(v1_3, 16), floormod(v0_3, 16), floormod(v1_3, 16)]
        }
      }
      for (i_0: int32, 0, 1024) {
        for (i_1: int32, 0, 16) {
          for (j_0: int32, 0, 1024) {
            for (j_1: int32, 0, 16) {
              for (k_0: int32, 0, 1024) {
                for (k_1: int32, 0, 16) {
                  block([16384, 16384, tir.reduce_axis(0, 16384)], "B") as [vi, vj, vk] {
                    bind(vi, ((i_0*16) + i_1))
                    bind(vj, ((j_0*16) + j_1))
                    bind(vk, ((k_0*16) + k_1))
                    tir.reads([A_global_shared[floordiv(vi, 16), floordiv(vk, 16), floormod(vi, 16), floormod(vk, 16)], B_global_shared[floordiv(vj, 16), floordiv(vk, 16), floormod(vj, 16), floormod(vk, 16)]])
                    tir.writes([C_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)]])
                    with init() {
                      C_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)] = 0
                    }
                    C_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)] = (C_global[floordiv(vi, 16), floordiv(vj, 16), floormod(vi, 16), floormod(vj, 16)] + (cast(int32, A_global_shared[floordiv(vi, 16), floordiv(vk, 16), floormod(vi, 16), floormod(vk, 16)])*cast(int32, B_global_shared[floordiv(vj, 16), floordiv(vk, 16), floormod(vj, 16), floormod(vk, 16)])))
                }
              }
            }
          }
        }
      }
      for (ax0_3: int32, 0, 16384) {
        for (ax1_3: int32, 0, 16384) {
          block([16384, 16384], "C_global") as [v0_4, v1_4] {
            bind(v0_4, ax0_3)
            bind(v1_4, ax1_3)
            tir.reads([C_global[floordiv(v0_4, 16), floordiv(v1_4, 16), floormod(v0_4, 16), floormod(v1_4, 16)]])
            tir.writes([C[v0_4, v1_4]])
            C[v0_4, v1_4] = C_global[floordiv(v0_4, 16), floordiv(v1_4, 16), floormod(v0_4, 16), floormod(v1_4, 16)]
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