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
const UPDATE_TIME = "update_time";

// 采样状态
const STATUS_FLOW1 = "StatusFlow1";
const STATUS_FLOW2 = "StatusFlow2";
const STATUS_FLOW3 = "StatusFlow3";
const STATUS_FLOW4 = "StatusFlow4";
const STATUS_FLOW5 = "StatusFlow5";
const STATUS_FLOW6 = "StatusFlow6";
const STATUS_FLOW7 = "StatusFlow7";
const STATUS_FLOW8 = "StatusFlow8";

// 分析
const STATUS_ANALY_0 = "StatusAnalysis0";
const STATUS_ANALY_1 = "StatusAnalysis1";
const STATUS_ANALY_2 = "StatusAnalysis2";
const STATUS_ANALY_3 = "StatusAnalysis3";
const STATUS_ANALY_4 = "StatusAnalysis4";

// 结束
const STATUS_IDLE = "StatusEndIdle";
const STATUS_END_FINISH = "StatusEndFinish";
const STATUS_END_STOP = "StatusEndStop";
const STATUS_END_FINISH2 = "StatusEndFinish2";

const STATUS_E1 = "StatusE1Inhale"
const STATUS_E2 = "StatusE2Inhale"
const STATUS_E3 = "StatusE3Hold"
const STATUS_E4 = "StatusE4Flow"
const STATUS_E5 = "StatusE5Flow"
const STATUS_E6 = "StatusE6Sample"
const STATUS_E7 = "StatusE7PHigh"
const STATUS_E8 = "StatusE8PLow"


const COMMAND_NONE = "None"
const COMMAND_FENO50_1 = "Feno50Train1"
const COMMAND_FENO50_2 = "Feno50Train2"
const COMMAND_FENO50_MODE1 = "Feno50Mode1"
const COMMAND_FENO50_MODE2 = "Feno50Mode2"



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

// 当前呼吸测试是否在采样
function is_helxa_sample(value) {
    let v = get_helxa_status(value);
    return v === HELXA_STATUS_SAMPLE
}

// 当前呼吸测试是否在分析
function is_helxa_analy(value) {
    let v = get_helxa_status(value);
    return v === HELXA_STATUS_ANAY
}

// 当前呼吸测试是否在已完成
function is_helxa_finish(value) {
    let v = get_helxa_status(value);
    return v === HELXA_STATUS_FINISH
}


const HELXA_STATUS_SAMPLE = 0
const HELXA_STATUS_ANAY = 1
const HELXA_STATUS_FINISH = 2

function get_helxa_status(value) {
    if(value === STATUS_FLOW1 ||value === STATUS_FLOW2 ||
            value === STATUS_FLOW3 ||value === STATUS_FLOW4 ||
            value === STATUS_FLOW5 ||value === STATUS_FLOW6 ||
            value === STATUS_FLOW7 ||value === STATUS_FLOW8 ) {
        return HELXA_STATUS_SAMPLE
    } else if (value === STATUS_ANALY_0 || value === STATUS_ANALY_1 ||
               value === STATUS_ANALY_2 || value === STATUS_ANALY_3 || value === STATUS_ANALY_4){
        return HELXA_STATUS_ANAY
    } else {
        return HELXA_STATUS_FINISH
    }
}

function get_status_info(value) {
    if(value === STATUS_E1) {
        return "未检测到吸气动作"
    } else if(value === STATUS_E2) {
        return "未检测到吸气动作"
    } else if(value === STATUS_E3) {
        return "未检测到吸气动作"
    }else if(value === STATUS_E4) {
        return "呼气流量过高"
    }else if(value === STATUS_E5) {
        return "呼气流量过低"
    }else if(value === STATUS_E6) {
        return "采样超时"
    }else if(value === STATUS_E7) {
        return "正压过大"
    }else if(value === STATUS_E8) {
        return "负压过大"
    } else if (value ===STATUS_END_STOP){
        return "手动停止"
    } else {
//        console.log("status = "+ value)
        return "手动停止"
    }

}


