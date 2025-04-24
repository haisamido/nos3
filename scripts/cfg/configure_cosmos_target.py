import sys
import os
import xml.etree.ElementTree as ET

components = {
    "arducam" : "cam",
    "cryptolib" : "cryptolib",
    "generic_adcs" : "adcs",
    "generic_css" : "css",
    "generic_eps" : "eps",
    "generic_fss" : "fss",
    "generic_imu" : "imu",
    "generic_mag" : "mag",
    "generic_radio" : "radio",
    "generic_reaction_wheel" : "rw",
    "generic_star_tracker" : "st",
    "generic_thruster" : "thruster",
    "generic_torquer" : "torquer",
    "mgr" : "mgr",
    "novatel_oem615" : "novatel_oem615",
    "onair" : "onair",
    "sample" : "sample",
    "syn" : "syn"
}

def main():
    mission_file = 'nos3-mission.xml'
    mission_tree = ET.parse("./cfg/build/temp_mission/" + os.path.basename(mission_file))
    mission_root = mission_tree.getroot()
    sc_cfg = mission_root.find("sc-1-cfg").text
    sc_cfg_str = './cfg/' + sc_cfg
    sc_tree = ET.parse(sc_cfg_str)
    sc_root = sc_tree.getroot()

    component = sys.argv[1]
    component = component.split('/')[-1]

    xml_path = 'components/{x}/enable'.format(x=components[component])
    component = component.upper()

    # Parse spacecraft configuration
    sc_component_en = None
    try:
        sc_component_en = sc_root.find(xml_path).text
    except AttributeError:
        pass

    if type(sc_component_en) == None:
        sys.exit()

    write_lines = []
    if sc_component_en == 'false':
        # remove the target from COSMOS
        with open("./gsw/cosmos/config/tools/cmd_tlm_server/cmd_tlm_server.txt", 'r') as fp:
            lines = fp.read().splitlines()
            for line in lines:
                if line in [
                    f'  TARGET {component}',
                    f'  TARGET GENERIC_{component}',
                    f'  TARGET {component}_RADIO',
                    f'  TARGET GENERIC_{component}_RADIO',
                    f'  TARGET SYNOPSIS',
                    f'  TARGET SYNOPSIS_RADIO'
                ]:
                    print("Removed:", line)
                else:
                    write_lines.append(line + "\n")
            fp.close()
    elif sc_component_en == 'true':
        # add the target to cosmos
        with open("./gsw/cosmos/config/tools/cmd_tlm_server/cmd_tlm_server.txt", 'r') as fp:
            line_found = False
            radio_found = False
            syn_found = False
            syn_radio_found = False
            interface = None
            lines = fp.read().splitlines()
            for line in lines:
                if line.split(" ")[0] == "INTERFACE" and interface != None:
                    # add lines if you reach the next interface
                    if line_found == False:
                        write_lines.append(f'  TARGET {component}\n')
                    if radio_found == False:
                        write_lines.append(f'TARGET {component}_RADIO\n')
                    if component == "SYN" and syn_found == False:
                        write_lines.append(f'  TARGET SYNOPSIS\n')
                    if component == "SYN" and syn_radio_found == False:
                        write_lines.append(f'  TARGET SYNOPSIS_RADIO\n')
                    interface = line.split()[1]
                elif line in [
                    f'  TARGET {component}',
                    f'  TARGET GENERIC_{component}',
                ]:
                    line_found = True
                elif line in [
                    f'  TARGET {component}_RADIO',
                    f'  TARGET GENERIC_{component}_RADIO',
                ]:
                    radio_found = True
                elif component == "SYN":
                    if line == f'  TARGET SYNOPSIS':
                        syn_found = True
                    if line == f'  TARGET SYNOPSIS_RADIO':
                        syn_radio_found = True
                write_lines.append(line + "\n")
            
            fp.close()

    if len(write_lines) > 0:
        os.remove("./gsw/cosmos/config/tools/cmd_tlm_server/cmd_tlm_server.txt")
        with open("./gsw/cosmos/config/tools/cmd_tlm_server/cmd_tlm_server.txt", 'a') as new_fp:
            new_fp.writelines(write_lines)
    

if __name__ == "__main__":
    main()
