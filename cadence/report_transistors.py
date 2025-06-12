import re
import argparse

def extract_gates_and_counts(report_text):
    """
    Extracts gate names, instance counts, and library from a synthesis report text.

    Args:
        report_text (str): The full text of the synthesis report.

    Returns:
        dict: A dictionary where keys are gate names and values are dictionaries
              containing 'instances' and 'library'.
    """
    gate_data = {}
    # Regex to find the start of the table section
    # This looks for the line containing "Gate Instances Area Leakage Power (nW) Library"
    # followed by a line of hyphens.
    start_marker_pattern = re.compile(r'\s*Gate\s+Instances\s+Area\s+Power \(nW\)\s+Library\s*\n-{50,}')
    # Regex to find the 'total' line which marks the end of the table
    end_marker_pattern = re.compile(r'^\s*total\s+\d+', re.MULTILINE)

    # Find the start and end of the relevant section
    start_match = start_marker_pattern.search(report_text)
    end_match = end_marker_pattern.search(report_text)

    if not start_match or not end_match:
        print("Could not find the gate instances section in the report.")
        return {}

    # Extract the section containing gate data
    start_index = start_match.end()
    end_index = end_match.start()
    gate_section = report_text[start_index:end_index]

    # Regex to capture the gate name (non-whitespace characters), the instance count (digits),
    # and the library name (non-whitespace characters at the end of the line).
    # We use \S+ for non-whitespace characters for the gate name and library, and \d+ for the instances.
    # The ^ ensures we match from the beginning of a line, and .*? matches any characters non-greedily
    # between the instance count and the library name.
    gate_pattern = re.compile(r'^\s*(\S+)\s+(\d+)\s+.*?(\S+)\s*$', re.MULTILINE)

    # Find all matches in the extracted section
    for match in gate_pattern.finditer(gate_section):
        gate_name = match.group(1)
        instances = int(match.group(2))
        library = match.group(3)
        gate_data[gate_name] = {'instances': instances, 'library': library}

    return gate_data


def extract_transistor_from_cdl(cdl_data, cell_name):
    """
    Extracts gate names, instance counts, and library from a synthesis report text.

    Args:
        cdl_data (str): Data from CDL File
        cell_name (str): Search for cell_name in Data

    Returns:
        transistor_count (int): Number of Transistors in Cell in the Given CDL
    """
    # Regex to find the start of the table section
    # This looks for the line containing "Gate Instances Area Leakage Power (nW) Library"
    # followed by a line of hyphens.

    pattern = re.compile(
    r'\.SUBCKT\s+' + re.escape(cell_name) + r'.*?\.ENDS',
    re.DOTALL | re.IGNORECASE
    )

    # start_marker_pattern = re.compile(r'\s*\.SUBCKT\s+' + re.escape(cell_name) + r'.*')
    # start_marker_pattern = re.compile(r'\s*\.SUBCKT\s+' + re.escape(cell_name) + r'\s+')

    # Regex to find the 'total' line which marks the end of the table
    # end_marker_pattern = re.compile(r'\s*.ENDS\n', re.MULTILINE)

    # Find the start and end of the relevant section
    # start_match = start_marker_pattern.search(cdl_data)
    # end_match = end_marker_pattern.search(cdl_data)
    # print(start_match)
    # print(end_match)
    # if not start_match or not end_match:
        # print("Could not find the gate instances section in the report.")
        # return -1
    match = pattern.search(cdl_data)

    if match:
        subckt_block = match.group()
        transistors = re.findall(r'\bMM\d+\b', subckt_block)
        transistor_list = list(set(transistors))
        transistor_count = len(transistor_list)
        # print(transistors)
        return transistor_count
    else:
        print("Subcircuit not found")
        return -1

    # print(cdl_data[:10])
    # Extract the section containing gate data
    # start_index = start_match.end()
    # end_index = end_match.start()
    # print(start_index)
    # print(end_index)
    # # print(cdl_data)
    # gate_section = cdl_data[start_index:end_index]
    # print(cdl_data[start_index:end_index])
    # matches = re.findall(r'\bMM\d+\b', gate_section)
    # # matches.append('MM7')
    # # print()
    # transistor_list = list(set(matches))
    # transistor_count = len(transistor_list)
    # # print(transistor_count)
    # return transistor_count 
    

if __name__ == '__main__':
    # Create the parser
    parser = argparse.ArgumentParser(
        description="Extract gate names and counts from synthesis reports or CDL files."
    )

    parser.add_argument(
        "--output",
        type=str,
        help="Path to a synthesis report file (.rpt). Example: --output my_synthesis.rpt"
    )
    parser.add_argument(
        "--cdl",
        type=str,
        help="Path to a directory containing CDL files (.cdl) for parsing. Example: --cdl ./netlists/common.cdl"
    )

    parser.add_argument(
        "--gate_report",
        type=str,
        help="Report file containing list of gate names (one per line) to filter the output. Example: --gate_report common_gates.rpt"
    )

    # Parse the command-line arguments
    args = parser.parse_args()
    
    rpt_gates = args.gate_report
    with open(rpt_gates) as fd_rpt_gates:
        rpt_gate_data = fd_rpt_gates.read()
    
    # print(rpt_gate_data)
    gates_features = extract_gates_and_counts(rpt_gate_data)
    
    cdl_file = args.cdl
    with open(cdl_file) as fd_cdl:
        cdl_data = fd_cdl.read()
    
    output_file = args.output
    fd_rpt = open(output_file, "w")
    if not fd_rpt:
        print(f"Output Report Not Created: {fd_rpt}")
    
    fd_rpt.write("File Generated by Custom Script\n")
    fd_rpt.write("Copyrights: Ali Aqdas (Purdue University)\n")
    total_transistors = 0
    for gate in gates_features:
        if gate == "DFFASRHQNx1_ASAP7_75t_L":
            gate_name = "DFFHQNx1_ASAP7_75t_L"
        else:
            gate_name = gate
        # print(f"Gate: {gate}, Instances: {gates_features[gate]['instances']} Library:{gates_features[gate]['library']}\n")
        transistor_count = extract_transistor_from_cdl(cdl_data, gate_name)
        fd_rpt.write(f"Net Transistor Count: {transistor_count * gates_features[gate]['instances']}, Transistor Per Cell: {transistor_count} Gate: {gate}, Instances: {gates_features[gate]['instances']} Library:{gates_features[gate]['library']}\n")
        # print(transistor_count)
        if gate != "DFFASRHQNx1_ASAP7_75t_L":
            total_transistors = total_transistors + (transistor_count * gates_features[gate]['instances'])
        else:
            print(f"Warning! The cell {gate} can not be found in {cdl_file}\n")
            if gate == "DFFASRHQNx1_ASAP7_75t_L":
                print(f"Estimating {gate} with {gate_name}\n")
                total_transistors = total_transistors + (transistor_count * gates_features[gate]['instances'])

        
    fd_rpt.write(f"Total Transistor Count: {total_transistors}\n")
    fd_rpt.close()
    

        
    