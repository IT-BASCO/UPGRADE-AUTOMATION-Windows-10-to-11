# 🧪 Testing Strategy

The goal of testing in this project is to ensure OS stability and zero interference with 24/7 operational services during the automatic upgrade from Windows 10 to 11.

## 1. Test Environments
All tests must be performed in isolated environments before execution in production:
* **Sandbox VM:** Virtual machines (e.g., ESXi or VMware Workstation) with hardware configurations identical to the target clients.
* **Snapshot Usage:** Take a snapshot of the virtual machine before each stage to ensure immediate rollback capability.

## 2. Test Phases
Tests must be conducted in the following three levels to minimize disruption risks:

### Phase A: Dry-Run Validation
Execute scripts using the 'WhatIf' switch to verify commands without applying changes. This ensures the integrity of registry paths and file sharing.

    # Dry-run execution for the disk optimization stage
    .\01-Disk-Optimizer.ps1 -WhatIf

### Phase B: Pilot Deployment
* **Target Population:** Execute the test on 10 systems across various departments (IT, HR, Finance).
* **Objective:** Verify that hardware bypasses (TPM/CPU) and LTSC edition conversions function correctly across different hardware models (Laptops/PCs).

### Phase C: Integrity Check
After the upgrade is complete, verify the system status:
* **Services:** Confirm that ManageEngine UEMS, OpManager, and Symantec Endpoint Protection are active.
* **Logs:** Check the log file in C:\Logs to ensure it reports SUCCESS.
* **Network Connectivity:** Ensure the system is accessible and properly joined to the domain (Domain Join Verification).

## 3. How to Report Test Failure
If you encounter any issues or bugs during the testing phases, please open a new report in the [Issues](https://github.com/absalan95mohammad/repo_name/issues) section and include the following information:

1. **System Specifications:** (CPU model, RAM capacity, current Windows version).
2. **Error Code:** (Script log output located at C:\Logs).
3. **Failure Stage:** (The specific stage of the pipeline where the error occurred).

---
*Responsible testing is the key to a secure upgrade.*
