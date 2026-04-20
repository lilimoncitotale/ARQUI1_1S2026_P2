AS = aarch64-linux-gnu-as -g
LD = aarch64-linux-gnu-ld -g
QEMU = qemu-aarch64

BUILD = build

IO_OBJ = $(BUILD)/io.o
MAIN_OBJ = $(BUILD)/main.o
TEST_INPUT_OBJ = $(BUILD)/test_input_matrix.o
TEST_ROW_OBJ = $(BUILD)/test_rowmajor.o
OPS_ID_OBJ = $(BUILD)/ops_identity.o
OPS_TR_OBJ = $(BUILD)/ops_transpose.o
OPS_DET_OBJ = $(BUILD)/ops_determinant.o
OPS_GAUSS_OBJ = $(BUILD)/ops_gauss.o
OPS_INV_OBJ = $(BUILD)/ops_det_inv.o
FIXED_MATH_OBJ = $(BUILD)/fixed_math.o

MAIN_BIN = $(BUILD)/app_main
TEST_INPUT_BIN = $(BUILD)/test_input_matrix
TEST_ROW_BIN = $(BUILD)/test_rowmajor

all: main

$(BUILD):
	mkdir -p $(BUILD)

$(IO_OBJ): src/io.s | $(BUILD)
	$(AS) src/io.s -o $(IO_OBJ)

$(MAIN_OBJ): src/main.s | $(BUILD)
	$(AS) src/main.s -o $(MAIN_OBJ)

$(OPS_ID_OBJ): src/ops_identity.s | $(BUILD)
	$(AS) src/ops_identity.s -o $(OPS_ID_OBJ)

$(OPS_TR_OBJ): src/ops_transpose.s | $(BUILD)
	$(AS) src/ops_transpose.s -o $(OPS_TR_OBJ)
$(OPS_DET_OBJ): src/ops_determinant.s | $(BUILD)
	$(AS) src/ops_determinant.s -o $(OPS_DET_OBJ)

$(OPS_GAUSS_OBJ): src/ops_gauss.s | $(BUILD)
	$(AS) src/ops_gauss.s -o $(OPS_GAUSS_OBJ)

$(OPS_INV_OBJ): src/ops_det_inv.s | $(BUILD)
	$(AS) src/ops_det_inv.s -o $(OPS_INV_OBJ)

$(FIXED_MATH_OBJ): src/fixed_math.s | $(BUILD)
	$(AS) src/fixed_math.s -o $(FIXED_MATH_OBJ)

$(TEST_INPUT_OBJ): src/test_input_matrix.s | $(BUILD)
	$(AS) src/test_input_matrix.s -o $(TEST_INPUT_OBJ)

$(TEST_ROW_OBJ): src/test_rowmajor.s | $(BUILD)
	$(AS) src/test_rowmajor.s -o $(TEST_ROW_OBJ)

main: $(MAIN_OBJ) $(IO_OBJ) $(OPS_ID_OBJ) $(OPS_TR_OBJ) $(OPS_DET_OBJ) $(OPS_GAUSS_OBJ) $(OPS_INV_OBJ) $(FIXED_MATH_OBJ)
	$(LD) $(MAIN_OBJ) $(IO_OBJ) $(OPS_ID_OBJ) $(OPS_TR_OBJ) $(OPS_DET_OBJ) $(OPS_GAUSS_OBJ) $(OPS_INV_OBJ) $(FIXED_MATH_OBJ) -o $(MAIN_BIN)

test-input: $(TEST_INPUT_OBJ) $(IO_OBJ)
	$(LD) $(TEST_INPUT_OBJ) $(IO_OBJ) -o $(TEST_INPUT_BIN)

test-row: $(TEST_ROW_OBJ) $(IO_OBJ)
	$(LD) $(TEST_ROW_OBJ) $(IO_OBJ) -o $(TEST_ROW_BIN)

run-main: main
	$(QEMU) $(MAIN_BIN)

run-test-input: test-input
	$(QEMU) $(TEST_INPUT_BIN)

run-test-row: test-row
	$(QEMU) $(TEST_ROW_BIN)

clean:
	rm -f $(BUILD)/*.o $(MAIN_BIN) $(TEST_INPUT_BIN) $(TEST_ROW_BIN)

.PHONY: all main test-input test-row run-main run-test-input run-test-row clean