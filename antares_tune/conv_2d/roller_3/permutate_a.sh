# nhwc * ohwi(nhwc)
# input_padding
# DEVICE_ID=3 BACKEND=c-cuda STEP=1000 COMPUTE_V1='- _N, _CI, _H, _W, _CO, _KH, _KW, _SH, _SW, _PH, _PW = 128, 1008, 42, 42, 336, 1, 1, 1, 1, 0, 0; _PHI, _PWI = _H + _PH * 2, _W + _PW * 2; einstein_v2(f"output0[N, C, PHI, PWI] = input0[N, C, -{_PH} + PHI, -{_PW} + PWI].when([-{_PH} + PHI >= 0, -{_PH} + PHI < {_H}, -{_PW} + PWI >= 0, -{_PW} + PWI < {_W}], const(0.0).cast(`float16`)) where PHI in {_PHI}, PWI in {_PWI}", input_dict={"input0": {"dtype": "float16", "shape": [_N, _H, _W, _CI]}})' antares save ./InputPadding.cu


# im2col

# input_padding+im2col
BACKEND=c-cuda STEP=10000 COMPUTE_V1='- _N, _CI, _H, _W, _CO, _KH, _KW, _SH, _SW, _PH, _PW = 128, 1008, 42, 42, 336, 1, 1, 1, 1, 0, 0;_HO, _WO = (_H - _KH + _PH * 2) // _SH + 1, (_W - _KW + _PW * 2) // _SW + 1;_PHI, _PWI = _H + _PH * 2, _W + _PW * 2; _GM, _GN, _GK = _N * _HO * _WO, _CO, _CI * _KH * _KW; einstein_v2(f"temp0[N, PHI, PWI, C] = input0[N, -{_PH} + PHI, -{_PW} + PWI, C].when([-{_PH} + PHI >= 0, -{_PH} + PHI < {_H}, -{_PW} + PWI >= 0, -{_PW} + PWI < {_W}], const(0.0).cast(`float16`)) where PHI in {_PHI}, PWI in {_PWI};output0[GM, GK] = temp0[GM // ({_HO} * {_WO}), {_SH} * ((GM % ({_HO} * {_WO})) // {_WO}) + (GK // {_CI}) // {_KW}, {_SW} * ((GM % ({_HO} * {_WO})) % {_WO}) + (GK // {_CI}) % {_KW}, GK % {_CI}] where GM in {_GM}, GK in {_GK}", input_dict={"input0": {"dtype": "float16", "shape": [_N, _H, _W, _CI]}})' antares save ./InputPadding_Im2col_ours.cu


# BACKEND=c-cuda STEP=1000 COMPUTE_V1='- N, C, F = 128, 1008, 336; HI = WI = 42; KW = KH = 1; SH = SW = 1; PH = PW = 0; HO = (HI - KH + PH * 2) // SH + 1; WO = (WI - KW + PW * 2) // SW + 1; einstein_v2(f"temp0[I, K] = input0[I / alter(`HOWO:{HO * WO}`), (I / alter(`WO:{WO}`) % alter(`HO:{HO}`) * alter(`SH:{SH}`) + K / alter(`KWC:{KW * C}`) - alter(`PH:{PH}`)), (I % alter(`WO:{WO}`) * alter(`SW:{SW}`) + K / alter(`C:{C}`) % alter(`KW:{KW}`) - alter(`PW:{PW}`)), K % alter(`C:{C}`)].when([I / alter(`WO:{WO}`) % alter(`HO:{HO}`) * alter(`SH:{SH}`) + K / alter(`KWC:{KW * C}`) - alter(`PH:{PH}`) >= 0, I / alter(`WO:{WO}`) % alter(`HO:{HO}`) * alter(`SH:{SH}`) + K / alter(`KWC:{KW * C}`) - alter(`PH:{PH}`) < alter(`HI:{HI}`), I % alter(`WO:{WO}`) * alter(`SW:{SW}`) + K / alter(`C:{C}`) % alter(`KW:{KW}`) - alter(`PW:{PW}`) >= 0, I % alter(`WO:{WO}`) * alter(`SW:{SW}`) + K / alter(`C:{C}`) % alter(`KW:{KW}`) - alter(`PW:{PW}`) < alter(`WI:{WI}`)], const(0.0).cast(`float16`)) where I in I:{N * HO * WO}, K in K:{KH * KW * C}", { "input0": {"dtype": "float16", "shape": [f"N:{N}", f"HI:{HI}", f"WI:{WI}", f"C:{C}"]}})' antares save ./InputPadding_Im2col.cu


# COMPUTE_V1='- _N, _CI, _H, _W, _CO, _KH, _KW, _SH, _SW, _PH, _PW = 16, 64, 32, 32, 256, 3, 3, 1, 1, 0, 0; _HO, _WO = (_H - _KH + _PH * 2) // _SH + 1, (_W - _KW + _PW * 2) // _SW + 1; einstein_v2(f"output0[N, F, HO, WO] +=! input0[N, C, HO * {_SH} + KH - {_PH}, WO * {_SW} + KW - {_PW}].when([HO * {_SH} + KH - {_PH} >= 0, HO * {_SH} + KH - {_PH} < {_H}, WO * {_SW} + KW - {_PW} >= 0, WO * {_SW} + KW - {_PW} < {_W}], 0.0) * input1[F, C, KH, KW] where HO in {_HO}, WO in {_WO}", { "input0": {"dtype": "float32", "shape": [_N, _CI, _H, _W]}, "input1": {"dtype": "float32", "shape": [_CO, _CI, _KH, _KW]}})' antares


# DEVICE_ID=3 BACKEND=c-cuda STEP=1000 COMPUTE_V1='- einstein_v2("output0[M, K] = ", input_dict={"input0": {"dtype": "float16", "shape": [128, 1008, 42, 42]}, "output0": {"dtype": "int8", "shape": [225792, 1008]}})' antares save ./a_permutation_16384_int8.cu
