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
** *****************************************************
** RTS 030 - Science Mode: Doing Science, Over AK Region
** *****************************************************
*/

/* Custom table structure, modify as needed to add desired commands */
typedef struct
{
    SC_RtsEntryHeader_t hdr1;
    MGR_U8_cmd_t cmd1;
    SC_RtsEntryHeader_t hdr2;
    MGR_NoArgs_cmd_t cmd2;
} SC_RtsStruct030_t;

/* Define the union to size the table correctly */
typedef union
{
    SC_RtsStruct030_t rts;
    uint16            buf[SC_RTS_BUFF_SIZE];
} SC_RtsTable030_t;

/* Helper macro to get size of structure elements */
#define SC_MEMBER_SIZE(member) (sizeof(((SC_RtsStruct030_t *)0)->member))

/* Used designated intializers to be verbose, modify as needed/desired */
SC_RtsTable030_t SC_Rts030 = {    
.rts = {
        /* 1 - Manager Note: Doing Science, Over AK Region */
        .hdr1.TimeTag = 1,
        .cmd1.CmdHeader = CFE_MSG_CMD_HDR_INIT(MGR_CMD_MID, SC_MEMBER_SIZE(cmd1), MGR_UPDATE_SCI_STATUS_CC, 0x00),
        .cmd1.U8 = SS_SCIENCE_OVER_AK,
        /* 2 - Increment Science Pass Counter */
        .hdr2.TimeTag = 1,
        .cmd2.CmdHeader = CFE_MSG_CMD_HDR_INIT(MGR_CMD_MID, SC_MEMBER_SIZE(cmd2), MGR_SCI_PASS_INC_CC, 0x00),
    }
};

/* Macro for table structure */
CFE_TBL_FILEDEF(SC_Rts030, SC.RTS_TBL030, SC Example RTS_TBL030, sc_rts030.tbl)
