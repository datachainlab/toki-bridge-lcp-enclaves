#include "Enclave_t.h"

#include "sgx_trts.h" /* for sgx_ocalloc, sgx_is_outside_enclave */
#include "sgx_lfence.h" /* for sgx_lfence */

#include <errno.h>
#include <mbusafecrt.h> /* for memcpy_s etc */
#include <stdlib.h> /* for malloc/free etc */

#define CHECK_REF_POINTER(ptr, siz) do {	\
	if (!(ptr) || ! sgx_is_outside_enclave((ptr), (siz)))	\
		return SGX_ERROR_INVALID_PARAMETER;\
} while (0)

#define CHECK_UNIQUE_POINTER(ptr, siz) do {	\
	if ((ptr) && ! sgx_is_outside_enclave((ptr), (siz)))	\
		return SGX_ERROR_INVALID_PARAMETER;\
} while (0)

#define CHECK_ENCLAVE_POINTER(ptr, siz) do {	\
	if ((ptr) && ! sgx_is_within_enclave((ptr), (siz)))	\
		return SGX_ERROR_INVALID_PARAMETER;\
} while (0)

#define ADD_ASSIGN_OVERFLOW(a, b) (	\
	((a) += (b)) < (b)	\
)


typedef struct ms_ecall_execute_command_t {
	sgx_status_t ms_retval;
	const uint8_t* ms_command;
	uint32_t ms_command_len;
	uint8_t* ms_out_buf;
	uint32_t ms_out_buf_maxlen;
	uint32_t* ms_out_buf_len;
} ms_ecall_execute_command_t;

typedef struct ms_ocall_execute_command_t {
	sgx_status_t ms_retval;
	const uint8_t* ms_command;
	uint32_t ms_command_len;
	uint8_t* ms_out_buf;
	uint32_t ms_out_buf_maxlen;
	uint32_t* ms_out_buf_len;
} ms_ocall_execute_command_t;

static sgx_status_t SGX_CDECL sgx_ecall_execute_command(void* pms)
{
	CHECK_REF_POINTER(pms, sizeof(ms_ecall_execute_command_t));
	//
	// fence after pointer checks
	//
	sgx_lfence();
	ms_ecall_execute_command_t* ms = SGX_CAST(ms_ecall_execute_command_t*, pms);
	ms_ecall_execute_command_t __in_ms;
	if (memcpy_s(&__in_ms, sizeof(ms_ecall_execute_command_t), ms, sizeof(ms_ecall_execute_command_t))) {
		return SGX_ERROR_UNEXPECTED;
	}
	sgx_status_t status = SGX_SUCCESS;
	const uint8_t* _tmp_command = __in_ms.ms_command;
	uint32_t _tmp_command_len = __in_ms.ms_command_len;
	size_t _len_command = _tmp_command_len * sizeof(uint8_t);
	uint8_t* _in_command = NULL;
	uint8_t* _tmp_out_buf = __in_ms.ms_out_buf;
	uint32_t _tmp_out_buf_maxlen = __in_ms.ms_out_buf_maxlen;
	size_t _len_out_buf = _tmp_out_buf_maxlen;
	uint8_t* _in_out_buf = NULL;
	uint32_t* _tmp_out_buf_len = __in_ms.ms_out_buf_len;
	size_t _len_out_buf_len = sizeof(uint32_t);
	uint32_t* _in_out_buf_len = NULL;
	sgx_status_t _in_retval;

	if (sizeof(*_tmp_command) != 0 &&
		(size_t)_tmp_command_len > (SIZE_MAX / sizeof(*_tmp_command))) {
		return SGX_ERROR_INVALID_PARAMETER;
	}

	CHECK_UNIQUE_POINTER(_tmp_command, _len_command);
	CHECK_UNIQUE_POINTER(_tmp_out_buf, _len_out_buf);
	CHECK_UNIQUE_POINTER(_tmp_out_buf_len, _len_out_buf_len);

	//
	// fence after pointer checks
	//
	sgx_lfence();

	if (_tmp_command != NULL && _len_command != 0) {
		if ( _len_command % sizeof(*_tmp_command) != 0)
		{
			status = SGX_ERROR_INVALID_PARAMETER;
			goto err;
		}
		_in_command = (uint8_t*)malloc(_len_command);
		if (_in_command == NULL) {
			status = SGX_ERROR_OUT_OF_MEMORY;
			goto err;
		}

		if (memcpy_s(_in_command, _len_command, _tmp_command, _len_command)) {
			status = SGX_ERROR_UNEXPECTED;
			goto err;
		}

	}
	if (_tmp_out_buf != NULL && _len_out_buf != 0) {
		if ( _len_out_buf % sizeof(*_tmp_out_buf) != 0)
		{
			status = SGX_ERROR_INVALID_PARAMETER;
			goto err;
		}
		if ((_in_out_buf = (uint8_t*)malloc(_len_out_buf)) == NULL) {
			status = SGX_ERROR_OUT_OF_MEMORY;
			goto err;
		}

		memset((void*)_in_out_buf, 0, _len_out_buf);
	}
	if (_tmp_out_buf_len != NULL && _len_out_buf_len != 0) {
		if ( _len_out_buf_len % sizeof(*_tmp_out_buf_len) != 0)
		{
			status = SGX_ERROR_INVALID_PARAMETER;
			goto err;
		}
		if ((_in_out_buf_len = (uint32_t*)malloc(_len_out_buf_len)) == NULL) {
			status = SGX_ERROR_OUT_OF_MEMORY;
			goto err;
		}

		memset((void*)_in_out_buf_len, 0, _len_out_buf_len);
	}
	_in_retval = ecall_execute_command((const uint8_t*)_in_command, _tmp_command_len, _in_out_buf, _tmp_out_buf_maxlen, _in_out_buf_len);
	if (memcpy_verw_s(&ms->ms_retval, sizeof(ms->ms_retval), &_in_retval, sizeof(_in_retval))) {
		status = SGX_ERROR_UNEXPECTED;
		goto err;
	}
	if (_in_out_buf) {
		if (memcpy_verw_s(_tmp_out_buf, _len_out_buf, _in_out_buf, _len_out_buf)) {
			status = SGX_ERROR_UNEXPECTED;
			goto err;
		}
	}
	if (_in_out_buf_len) {
		if (memcpy_verw_s(_tmp_out_buf_len, _len_out_buf_len, _in_out_buf_len, _len_out_buf_len)) {
			status = SGX_ERROR_UNEXPECTED;
			goto err;
		}
	}

err:
	if (_in_command) free(_in_command);
	if (_in_out_buf) free(_in_out_buf);
	if (_in_out_buf_len) free(_in_out_buf_len);
	return status;
}

SGX_EXTERNC const struct {
	size_t nr_ecall;
	struct {void* ecall_addr; uint8_t is_priv; uint8_t is_switchless;} ecall_table[1];
} g_ecall_table = {
	1,
	{
		{(void*)(uintptr_t)sgx_ecall_execute_command, 0, 0},
	}
};

SGX_EXTERNC const struct {
	size_t nr_ocall;
	uint8_t entry_table[1][1];
} g_dyn_entry_table = {
	1,
	{
		{0, },
	}
};


sgx_status_t SGX_CDECL ocall_execute_command(sgx_status_t* retval, const uint8_t* command, uint32_t command_len, uint8_t* out_buf, uint32_t out_buf_maxlen, uint32_t* out_buf_len)
{
	sgx_status_t status = SGX_SUCCESS;
	size_t _len_command = command_len * sizeof(uint8_t);
	size_t _len_out_buf = out_buf_maxlen;
	size_t _len_out_buf_len = sizeof(uint32_t);

	ms_ocall_execute_command_t* ms = NULL;
	size_t ocalloc_size = sizeof(ms_ocall_execute_command_t);
	void *__tmp = NULL;

	void *__tmp_out_buf = NULL;
	void *__tmp_out_buf_len = NULL;

	CHECK_ENCLAVE_POINTER(command, _len_command);
	CHECK_ENCLAVE_POINTER(out_buf, _len_out_buf);
	CHECK_ENCLAVE_POINTER(out_buf_len, _len_out_buf_len);

	if (ADD_ASSIGN_OVERFLOW(ocalloc_size, (command != NULL) ? _len_command : 0))
		return SGX_ERROR_INVALID_PARAMETER;
	if (ADD_ASSIGN_OVERFLOW(ocalloc_size, (out_buf != NULL) ? _len_out_buf : 0))
		return SGX_ERROR_INVALID_PARAMETER;
	if (ADD_ASSIGN_OVERFLOW(ocalloc_size, (out_buf_len != NULL) ? _len_out_buf_len : 0))
		return SGX_ERROR_INVALID_PARAMETER;

	__tmp = sgx_ocalloc(ocalloc_size);
	if (__tmp == NULL) {
		sgx_ocfree();
		return SGX_ERROR_UNEXPECTED;
	}
	ms = (ms_ocall_execute_command_t*)__tmp;
	__tmp = (void *)((size_t)__tmp + sizeof(ms_ocall_execute_command_t));
	ocalloc_size -= sizeof(ms_ocall_execute_command_t);

	if (command != NULL) {
		if (memcpy_verw_s(&ms->ms_command, sizeof(const uint8_t*), &__tmp, sizeof(const uint8_t*))) {
			sgx_ocfree();
			return SGX_ERROR_UNEXPECTED;
		}
		if (_len_command % sizeof(*command) != 0) {
			sgx_ocfree();
			return SGX_ERROR_INVALID_PARAMETER;
		}
		if (memcpy_verw_s(__tmp, ocalloc_size, command, _len_command)) {
			sgx_ocfree();
			return SGX_ERROR_UNEXPECTED;
		}
		__tmp = (void *)((size_t)__tmp + _len_command);
		ocalloc_size -= _len_command;
	} else {
		ms->ms_command = NULL;
	}

	if (memcpy_verw_s(&ms->ms_command_len, sizeof(ms->ms_command_len), &command_len, sizeof(command_len))) {
		sgx_ocfree();
		return SGX_ERROR_UNEXPECTED;
	}

	if (out_buf != NULL) {
		if (memcpy_verw_s(&ms->ms_out_buf, sizeof(uint8_t*), &__tmp, sizeof(uint8_t*))) {
			sgx_ocfree();
			return SGX_ERROR_UNEXPECTED;
		}
		__tmp_out_buf = __tmp;
		if (_len_out_buf % sizeof(*out_buf) != 0) {
			sgx_ocfree();
			return SGX_ERROR_INVALID_PARAMETER;
		}
		memset_verw(__tmp_out_buf, 0, _len_out_buf);
		__tmp = (void *)((size_t)__tmp + _len_out_buf);
		ocalloc_size -= _len_out_buf;
	} else {
		ms->ms_out_buf = NULL;
	}

	if (memcpy_verw_s(&ms->ms_out_buf_maxlen, sizeof(ms->ms_out_buf_maxlen), &out_buf_maxlen, sizeof(out_buf_maxlen))) {
		sgx_ocfree();
		return SGX_ERROR_UNEXPECTED;
	}

	if (out_buf_len != NULL) {
		if (memcpy_verw_s(&ms->ms_out_buf_len, sizeof(uint32_t*), &__tmp, sizeof(uint32_t*))) {
			sgx_ocfree();
			return SGX_ERROR_UNEXPECTED;
		}
		__tmp_out_buf_len = __tmp;
		if (_len_out_buf_len % sizeof(*out_buf_len) != 0) {
			sgx_ocfree();
			return SGX_ERROR_INVALID_PARAMETER;
		}
		memset_verw(__tmp_out_buf_len, 0, _len_out_buf_len);
		__tmp = (void *)((size_t)__tmp + _len_out_buf_len);
		ocalloc_size -= _len_out_buf_len;
	} else {
		ms->ms_out_buf_len = NULL;
	}

	status = sgx_ocall(0, ms);

	if (status == SGX_SUCCESS) {
		if (retval) {
			if (memcpy_s((void*)retval, sizeof(*retval), &ms->ms_retval, sizeof(ms->ms_retval))) {
				sgx_ocfree();
				return SGX_ERROR_UNEXPECTED;
			}
		}
		if (out_buf) {
			if (memcpy_s((void*)out_buf, _len_out_buf, __tmp_out_buf, _len_out_buf)) {
				sgx_ocfree();
				return SGX_ERROR_UNEXPECTED;
			}
		}
		if (out_buf_len) {
			if (memcpy_s((void*)out_buf_len, _len_out_buf_len, __tmp_out_buf_len, _len_out_buf_len)) {
				sgx_ocfree();
				return SGX_ERROR_UNEXPECTED;
			}
		}
	}
	sgx_ocfree();
	return status;
}

