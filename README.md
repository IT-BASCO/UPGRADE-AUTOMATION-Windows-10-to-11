<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11">
    <img src="images/logo.png" alt="Logo" width="380" height="280">
  </a>

  <h3 align="center">UPGRADE-AUTOMATION-Windows-10-to-11 </h3>

  <p align="center">
    An awesome README template to jumpstart your projects!
    <br />
    <a href="https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11">View Demo</a>
    ·
    <a href="https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [🏢 About The Project](#about-the-project)
* [🚀 Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Configuration & Deployment](#configuration--deployment)

* [⚙️ Framework Pipeline Stages](#framework-pipeline-stages)

    * [Stage 1: Disk Space Optimization](#stage-1-disk-space-optimization)
	
    * [Stage 2: Registry Safeguard](#stage-2-registry-safeguard)
	
    * [Stage 3: In-Place Migration Engine](#stage-3-in-place-migration-engine)
	
    * [Stage 4: Post-Deployment Agent Healing](#stage-4-post-deployment-agent-healing)
    
    * [Stage 5: Post-Upgrade Storage Reclaimer](#stage-5-post-upgrade-storage-reclaimer)
	

* [🛡️ Security & Compliance](#security--compliance)
* [💻 Usage](#usage)
* [🗺️ Roadmap](#roadmap)
* [🤝 Contributing](#contributing)
* [📜 License](#license)
* [📧 Contact](#contact)
* [✨ Acknowledgments](#acknowledgments)


<!-- ABOUT THE PROJECT -->
<a name="about-the-project"></a>
# 🏢 About The Project
[![Product Name Screen Shot][product-screenshot]](https://example.com)


Following the End-of-Life (EOL) announcement for Windows 10, large enterprises face critical security and compliance risks. Manually upgrading a decentralized fleet of endpoints introduces staggering operational bottlenecks. 

This project shifts infrastructure operations from traditional, high-risk manual updates to a deterministic, **fully automated background deployment pipeline**. By dynamically bypassing hardware checks, transforming LTSC environments to standard enterprise editions, and ensuring post-migration agent persistence, this framework solves the upgrade lifecycle with zero user disruption and zero graphical pop-ups.

### ⚡ The Enterprise Challenge Solved

* **Massive Geographical Dispersion:** Deploying updates across extensive industrial complexes spanning over **650 hectares** makes manual technician intervention logistically impossible.
* **Manpower & Resource Constraints:** Limited IT infrastructure personnel to handle a large fleet of active client nodes (**~170 systems**) simultaneously.
* **Hardware Incompatibility Obstacles:** Legacy workstations failing strict Windows 11 hardware checks (TPM 2.0, Secure Boot, unsupported legacy Core i3 CPU generations).
* **Capital Expenditure (CAPEX) Restrictions:** High hardware procurement costs avoided by circumventing forced hardware replacements and manual BIOS upgrades.

<a name="build-with"></a>
### 🛠️ Built With

* [![PowerShell][PowerShell-shield]][PowerShell-url]
* [![Windows][Windows-shield]][Windows-url]


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
<a name="getting-started"><a/>
# 🚀 Getting Started

<a name="prerequisites"></a>
### 📋 Prerequisites

* Target clients must be running Windows 10 Pro / Enterprise / LTSC.
* Administrative privileges on the target endpoints (via GPO or Endpoint Management tool).
* A centralized network file share containing the Windows 11 ISO installation media and software payloads.

<a name="configuration--deployment"></a>
### 🛠️ Configuration & Deployment

1. Clone the repository and navigate to the `src/` directory.
2. Open `02-Registry-Safeguard.bat` and `03-Migration-Engine.bat` to customize your centralized update share paths:
   ```batch
   set "CENTRAL_UPDATE_SHARE=\\<YOUR_FILE_SERVER_IP>\update"
   set "KMS_SERVER=kms.yourdomain.com"
   ```
3. Open `04-Agent-Healing.ps1` to adjust your infrastructure logging parameters:
   ```powershell
   param(
       [string]$SourceShare = "\\<YOUR_FILE_SERVER_IP>\update\agents",
       [string]$LogRoot = "\\<YOUR_FILE_SERVER_IP>\update\logs\agents"
   )
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- FRAMEWORK PIPELINE STAGES -->
<a name="framework-pipeline-stages"></a>
# ⚙️ Framework Pipeline Stages

The architecture consists of 5 sequential execution stages located in the `src/` folder:

```
[Target Endpoint]
       │
       ├──► Stage 1: 01-Disk-Optimizer.ps1       (Reclaims capacity, analyzes profiles)
       ├──► Stage 2: 02-Registry-Safeguard.bat    (Locale-independent HKLM registry backup)
       ├──► Stage 3: 03-Migration-Engine.bat      (TPM bypass, LTSC morphing, silent OS upgrade)
       ├──► Stage 4: 04-Agent-Healing.ps1         (Zero-GUI, asynchronous security agent injection)
       └──► Stage 5: 05-Post-Upgrade-Cleanup.bat  (Deep purge of Windows.old & setup caches)
```
<a name="stage-1-disk-space-optimization"></a>
### 🦾 Stage 1: Disk Space Optimization (`01-Disk-Optimizer.ps1`)
* **Purpose:** Proactively prepares the local primary volume for the heavy upgrade footprint.
* **Mechanics:** Performs deep analytical sweeps of user profiles, archives massive duplicate or stagnant folders, cleans temporary update storage blocks, and generates automated local reports before signaling readiness.

<a name="stage-2-registry-safeguard"></a>
### 🛡️ Stage 2: Registry Safeguard (`02-Registry-Safeguard.bat`)
* **Purpose:** Ensures high-availability system resilience before major OS modifications.
* **Mechanics:** Executes a native registry export of the core `HKLM` hives. Utilizes a **Base-PowerShell parsing engine** to extract date metrics, successfully bypassing legacy DOS date parsing bugs commonly triggered by Persian/Solar Hijri or local system regional settings.

<a name="stage-3-in-place-migration-engine"></a>
### ⚙️ Stage 3: In-Place Migration Engine (`03-Migration-Engine.bat`)
* **Purpose:** The central core that performs the unattended upgrade payload injection.
* **Mechanics:**
  * Instantly blocks deployment on critical Windows Servers to prevent domain controller or infrastructure corruption.
  * Bypasses Windows 11 TPM 2.0, RAM, and CPU checks via registry-level hardware spoofing.
  * Dynamically detects **Windows 10 LTSC** versions and temporarily morphs their identity parameters to standard Enterprise, preventing the classic upgrade blockade.
  * Flushes legacy licensing keys and reinjects standard Enterprise GVLKs aligned with central KMS activation servers.

<a name="stage-4-post-deployment-agent-healing"></a>
### 🧪 Stage 4: Post-Deployment Agent Healing (`04-Agent-Healing.ps1`)
* **Purpose:** Re-establishes corporate visibility, endpoint management, and security posture instantly upon OS boot.
* **Mechanics:** Runs completely headless (`WindowStyle Hidden` / `Zero-GUI`) without disrupting the active user or throwing security pop-ups. Scans, reinstalls, and validates the running health of critical corporate background daemons:
  * **ManageEngine UEMS** (`DesktopCentralAgent`)
  * **ManageEngine OpManager** (`OpManagerAgent`)
  * **Symantec Endpoint Protection** (`SepMasterService`)
  * **NetSupport Support Client** (`Client32`)

<a name="stage-5-post-upgrade-storage-reclaimer"></a>
### 🧹 Stage 5: Post-Upgrade Storage Reclaimer (`05-Post-Upgrade-Cleanup.bat`)
* **Purpose:** Final cleanup phase executed days after verified endpoint stability to recover storage.
* **Mechanics:** Overrides advanced system file permissions using automated `takeown` and administrative `icacls` pipelines. Safely forces the destruction of heavy legacy artifacts including `C:\Windows.old`, `$WINDOWS.~BT`, `$WINDOWS.~WS`, diagnostic `Win11Logs`, and telemetry-heavy Panther setup dumps, followed by an automated system realignment reboot.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- Security & Compliance-->
<a name="security--compliance"></a>
# 🛡️ Security & Compliance
- **Permissions:** Requires **Administrator** privileges to modify registry keys.
- **Transparency:** This tool creates local logs in `C:\Logs`. No data is transmitted to external servers.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
<a name="usage"></a>
# 💻 Usage

You can orchestrate the execution sequence sequentially using **Active Directory Group Policy Objects (GPOs)**, **System Startup/Shutdown Scripts**, or your centralized endpoint management tool targeted directly at client operating systems.

For automated logging monitoring, check the central repository file share configured in Stage 4 to trace real-time execution summaries across all 170 nodes:
```text
[2026-07-07 10:46:17] [WIN10-FREE2-84] [V12.8] [SUMMARY] Final Status -> EC: OK, OM: OK, SYM: OK, NS: OK
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
<a name="roadmap"></a>
# 🗺️ Roadmap

See the [open issues](https://github.com/IT-BASCO/UPGRADE-AUTOMATION-Windows-10-to-11/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
<a name="contributing"></a>
# 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

For details on how to contribute, please see our [CONTRIBUTING.md](CONTRIBUTING.md) file.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
<a name="license"></a>
# 📜 License
Distributed under the **MIT License**. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
<a name="contact"></a>
# 📧 Contact

**Lead Systems Administrators:**

* **Vahid Soltaninejad** | [linkedin](https://linkedin.com/in/vahid-soltani-nejad) | `vsntxt@gmail.com`

* **Mohammad Absalan**  | [linkedin](https://linkedin.com/in/mohammad-absalan) | `absalan95mohammad@gmail.com`


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
<a name="acknowledgments"></a>
# ✨ Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[product-screenshot]: images/screenshot.png
[PowerShell-shield]: https://img.shields.io/badge/PowerShell-%235391FE.svg?style=plastic&logo=powershell&logoColor=white
[PowerShell-url]: https://learn.microsoft.com/en-us/powershell/
[Windows-shield]: https://img.shields.io/badge/Windows-0078D6?style=plastic&logo=windows&logoColor=white
[Windows-url]: https://www.microsoft.com/windows

