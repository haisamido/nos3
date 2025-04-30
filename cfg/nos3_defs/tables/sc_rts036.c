#include "cfe.h"
#include "cfe_tbl_filedef.h"

#include "sc_tbldefs.h"      /* defines SC table headers */
#include "sc_platform_cfg.h" /* defines table buffer size */
#include "sc_msgdefs.h"      /* defines SC command code values */
#include "sc_msgids.h"       /* defines SC packet msg ID's */
#include "sc_msg.h"          /* defines SC message structures */

/* Command Includes */
#include "cam_app.h"
#include "generic_radio_app.h"
#include "generic_eps_app.h"
#include "generic_eps_msgids.h"
#include "generic_eps_msg.h"
#include "sample_app.h"
#include "lc_app.h"
#include "lc_msgids.h"
#include "mgr_msgids.h"
#include "mgr_app.h"

/* 
** ************************************************
** RTS 036 - Sample Device Fail in Science Mode
** ************************************************
*/

/* Custom table structure, modify as needed to add desired commands */
typedef struct
{
    /* 11 - Disable Instrument Application */
    SC_RtsEntryHeader_t hdr11;
    SAMPLE_NoArgs_cmd_t cmd11;
    /* 12 - Disable Instrument Switch on EPS*/
    SC_RtsEntryHeader_t hdr12;
    GENERIC_EPS_Switch_cmd_t cmd12;
    /* 13 - Reset AP 26 - Go to Science Mode */
    SC_RtsEntryHeader_t hdr13;
    LC_ResetAPStats_t cmd13;
    /* 14 - Enable AP 26 - Go to Science Mode */
    SC_RtsEntryHeader_t hdr14;
    LC_SetAPState_t cmd14;
} SC_RtsStruct036_t;

/* Define the union to size the table correctly */
typedef union
{
    SC_RtsStruct036_t rts;
    uint16            buf[SC_RTS_BUFF_SIZE];
} SC_RtsTable036_t;

/* Helper macro to get size of structure elements */
#define SC_MEMBER_SIZE(member) (sizeof(((SC_RtsStruct036_t *)0)->member))

/* Used designated intializers to be verbose, modify as needed/desired */
SC_RtsTable036_t SC_Rts036 = {    
.rts = {
        /* 11 - Disable Instrument Application */
        .hdr11.TimeTag = 1,
        .cmd11.CmdHeader = CFE_MSG_CMD_HDR_INIT(SAMPLE_CMD_MID, SC_MEMBER_SIZE(cmd11), SAMPLE_DISABLE_CC, 0x00),
        /* 12 - Disable Instrument Switch on EPS*/
        .hdr12.TimeTag = 1,
        .cmd12.CmdHeader = CFE_MSG_CMD_HDR_INIT(GENERIC_EPS_CMD_MID, SC_MEMBER_SIZE(cmd12), GENERIC_EPS_SWITCH_CC, 0x00),
        .cmd12.SwitchNumber = 0,
        .cmd12.State = 0x00,
        /* 13 - Reset AP 26 - Go to Science Mode */
        .hdr13.TimeTag = 1,
        .cmd13.CmdHeader = CFE_MSG_CMD_HDR_INIT(LC_CMD_MID, SC_MEMBER_SIZE(cmd13), LC_RESET_AP_STATS_CC, 0x00),
        .cmd13.APNumber = 26,
        .cmd13.Padding = 0,
        /* 14 - Enable AP 26 - Go to Science Mode */
        .hdr14.TimeTag = 1,
        .cmd14.CmdHeader = CFE_MSG_CMD_HDR_INIT(LC_CMD_MID, SC_MEMBER_SIZE(cmd14), LC_SET_AP_STATE_CC, 0x00),
        .cmd14.APNumber = 26,
        .cmd14.NewAPState = LC_APSTATE_ACTIVE,
    }
};
/* Macro for table structure */
CFE_TBL_FILEDEF(SC_Rts036, SC.RTS_TBL036, SC Example RTS_TBL036, sc_rts036.tbl)
