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
#include "sample_app.h"
#include "mgr_msgids.h"
#include "mgr_app.h"

/* 
** ********************************************************
** RTS 034 - Science Mode: Idle Science, Left CONUS Region
** ********************************************************
*/

/* Custom table structure, modify as needed to add desired commands */
typedef struct
{
    SC_RtsEntryHeader_t hdr1;
    MGR_U8_cmd_t cmd1;
} SC_RtsStruct034_t;

/* Define the union to size the table correctly */
typedef union
{
    SC_RtsStruct034_t rts;
    uint16            buf[SC_RTS_BUFF_SIZE];
} SC_RtsTable034_t;

/* Helper macro to get size of structure elements */
#define SC_MEMBER_SIZE(member) (sizeof(((SC_RtsStruct034_t *)0)->member))

/* Used designated intializers to be verbose, modify as needed/desired */
SC_RtsTable034_t SC_Rts034 = {    
.rts = {
        /* 1 - Manager Note: Idle Science, Left CONUS Region */
        .hdr1.TimeTag = 1,
        .cmd1.CmdHeader = CFE_MSG_CMD_HDR_INIT(MGR_CMD_MID, SC_MEMBER_SIZE(cmd1), MGR_UPDATE_SCI_STATUS_CC, 0x00),
        .cmd1.U8 = SS_NO_SCIENCE_LEFT_CONUS,
    }
};

/* Macro for table structure */
CFE_TBL_FILEDEF(SC_Rts034, SC.RTS_TBL034, SC Example RTS_TBL034, sc_rts034.tbl)
