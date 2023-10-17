.pragma library

const SYS_CNT = "DSA_R16_SYS_CNT";
const DEVICE_STATUS = "DSA_R16_DEVICE_STATUS";
const FUNC_NAME = "DSA_R16_FUNC_NAME";
const FUNC_ACK = "DSA_R16_FUNC_ACK";
const FUNC_STATUS = "DSA_R16_FUNC_STATUS";
const UMD1_STATUS = "DSA_R16_UMD1_STATUS";
const UMD2_STATUS = "DSA_R16_UMD2_STATUS";
const FLOW_CNT = "DSA_R16_FLOW_CNT";
const FLOW_SIZE = "DSA_R16_FLOW_SIZE";
const FLOW_RT = "DSA_R16_FLOW_RT";
const FLOW_TIME = "DSA_R16_FLOW_TIME";
const TRACE_CNT = "DSA_R16_TRACE_CNT";
const TRACE_SIZE = "DSA_R16_TRACE_SIZE";
const TRACE_UMD1 = "DSA_R16_TRACE_UMD1";
const TRACE_UMD2 = "DSA_R16_TRACE_UMD2";
const AMBIENT_PRESS = "DSA_R16_AMBIENT_PRESS";
const AMBIENT_TEMP = "DSA_R16_AMBIENT_TEMP";
const AMBIENT_HUMI = "DSA_R16_AMBIENT_HUMI";
const RTC_UNIX1 = "DSA_R16_RTC_UNIX1";
const RTC_UNIX2 = "DSA_R16_RTC_UNIX2";
const TRACE_UMD1_TEMP = "DSA_R16_TRACE_UMD1_TEMP";
const TRACE_UMD2_TEMP = "DSA_R16_TRACE_UMD2_TEMP";
const FLOW_TEMP = "DSA_R16_FLOW_TEMP";
const FLOW_HUMI = "DSA_R16_FLOW_HUMI";
const FSM_CNT = "DSA_R16_FSM_CNT";
const FSM_FAULTFSM = "DSA_R16_FSM_FAULTFSM";
const FSM_PRESS_DIFFFSM = "DSA_R16_FSM_PRESS_DIFFFSM";
const FSM_FLOW = "DSA_R16_FSM_FLOW";
const FSM_SAMPLE_HUMI = "DSA_R16_FSM_SAMPLE_HUMI";
const FSM_SAMPLE_TEMP = "DSA_R16_FSM_SAMPLE_TEMP";
const FSM_AMBIENT_HUMI = "DSA_R16_FSM_AMBIENT_HUMI";
const FSM_AMBIENT_TEMP = "DSA_R16_FSM_AMBIENT_TEMP";
const FSM_ATMOS_X1000 = "DSA_R16_FSM_ATMOS_X1000";
const FSM_ATMOS_X1FSM = "DSA_R16_FSM_ATMOS_X1FSM";
const FSM_ATMOS_BASE_X1000 = "DSA_R16_FSM_ATMOS_BASE_X1000";
const FSM_ATMOS_BASE_X1 = "DSA_R16_FSM_ATMOS_BASE_X1";
const FSM_ATMOS_PRESS_DIFF = "DSA_R16_FSM_ATMOS_PRESS_DIFF";
const UMD1_CNT = "DSA_R16_UMD1_CNT";
const UMD1_FAULT = "DSA_R16_UMD1_FAULT";
const UMD1_VBAT = "DSA_R16_UMD1_VBAT";
const UMD1_VREF = "DSA_R16_UMD1_VREF";
const UMD1_TEMPER = "DSA_R16_UMD1_TEMPER";
const UMD1_ADC_CNT = "DSA_R16_UMD1_ADC_CNT";
const UMD1_ADC_DELTA = "DSA_R16_UMD1_ADC_DELTA";
const UMD1_ADC_DELTA_AVG = "DSA_R16_UMD1_ADC_DELTA_AVG";
const UMD1_ADC_SEN = "DSA_R16_UMD1_ADC_SEN";
const UMD1_ADC_SEN_AVG = "DSA_R16_UMD1_ADC_SEN_AVG";
const UMD1_ADC_AUX = "DSA_R16_UMD1_ADC_AUX";
const UMD1_ADC_AUX_AVG = "DSA_R16_UMD1_ADC_AUX_AVG";

var _sample_values = [
            FUNC_STATUS,
            FLOW_RT,
            FUNC_ACK,
            FUNC_NAME,
            AMBIENT_TEMP,
            TRACE_UMD1_TEMP,
            TRACE_UMD1
        ]

function get_sample_req(delay) {
    return {
        "method": "get_sample",
        "args": _sample_values,
        "delay": delay
    }
}

function get_start_helxa_req(command) {
    return {
        "method":"start_exhale_test",
        "args":[command]
    }
}

function get_stop_helxa_req() {
    return {
        "method":"stop_exhale_test",
    }
}

function is_helxa_starting(value) {
    var s = value.toUpperCase()
    if(s === "STATUSENDSTOP" || s === "STATUSENDFINISH"){
        return false
    } else {
        return true
    }
}
