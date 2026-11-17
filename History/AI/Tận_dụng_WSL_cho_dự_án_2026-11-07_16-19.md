# Tận dụng WSL cho dự án

**Exported:** 2026-11-07T09:19:47.092Z

**Work Directory:** `D:\Lab`

---

### **You**

bạn nghĩ thử cho tôi xem có thể tận dụng wsl để làm dự án này không, tận dụng và đóng gói tối đa tài nguyên vào wsl thì sao, thảo luận với tôi

### **Assistant**

[hook: SessionStart] succeeded (exit 0)

[hook: SessionStart] succeeded (exit 0)

[hook: SessionStart] succeeded (exit 0)

[hook: UserPromptSubmit] succeeded (exit 0)

#### Thinking

**Planning WSL brainstorming approach****Preparing to invoke brainstorming skill****Assessing project structure for WSL use**

#### Thinking

**Assessing WSL resource and network configurations****Considering systemd auto-start for WSL services**

Mình sẽ dùng khung brainstorming để cùng bạn phân ranh giới: phần nào nên đưa vào WSL, phần nào nên giữ ở Windows, rồi mới chốt mô hình vận hành phù hợp.

#### Tool: Skill

**Input:**

```json
{
  "skill": "superpowers:brainstorming",
  "args": "Người dùng muốn thảo luận khả năng tận dụng WSL2 để chứa và vận hành tối đa tài nguyên của dự án hiện tại. Chưa yêu cầu sửa code hay triển khai; hãy giúp khám phá mục tiêu, loại workload, giới hạn Windows/WSL, và các phương án kiến trúc thực tế bằng tiếng Việt."
}
```

**Response:**

Launching skill: superpowers:brainstorming

#### Thinking

**Planning feasibility classification announcement****Drafting concise Vietnamese spike approval request****Adding optional lazy alternative mention**

Đây là **spike khả thi**: đầu ra là một khuyến nghị kiến trúc, chưa viết code hay thay đổi cấu hình.

Tôi sẽ kiểm tra nhanh cấu trúc dự án và workload hiện tại, sau đó so sánh 3 hướng:

1. Đưa gần như toàn bộ runtime, dependency và dữ liệu vào WSL2.
2. Mô hình hybrid: code/runtime trong WSL, GPU/GUI/dịch vụ Windows giữ bên ngoài.
3. Giữ Windows làm host chính, chỉ dùng WSL cho build, container hoặc tooling.

Tôi sẽ tập trung vào hiệu năng I/O, GPU, networking, lưu trữ, backup, khả năng đóng gói và chi phí vận hành. Cách lười nhưng thường đúng là **chỉ đưa phần Linux-native và service cần tái lập vào WSL**, không chuyển mọi thứ nếu không có lợi ích rõ ràng.

Nếu đồng ý với phạm vi này, trả lời “được”; tôi sẽ bắt đầu khảo sát dự án rồi trao đổi từng lựa chọn với bạn.

[hook: Stop] succeeded (exit 0)

[hook: Stop] succeeded (exit 0)

### **You**

được, thực hiện khảo sát môi trường wsl đi

### **Assistant**

[hook: UserPromptSubmit] succeeded (exit 0)

#### Thinking

**Planning WSL environment survey tasks****Designing WSL and project inspection commands****Planning distro listing and task creation**

#### Thinking

**Creating initial task list**

Mình sẽ kiểm tra ba lớp: WSL/distribution đang cài, tài nguyên và cấu hình host, rồi đối chiếu với cấu trúc `D:\Lab` để xem workload nào hợp lý khi chuyển vào Linux.

#### Thinking

**Planning WSL environment survey****Designing parallel WSL and project surveys****Planning WSL config and status inspection**

#### Thinking

**Planning system and WSL inspection commands****Deciding WSL config reading strategy and system checks**

#### Tool: Agent

**Input:**

```json
{
  "description": "Khảo sát cấu trúc D Lab",
  "prompt": "Đây là một spike chỉ khảo sát, không sửa file. Hãy đọc cấu trúc hiện tại của workspace D:\\Lab (hoặc cwd được cung cấp), tìm các dự án/thư mục chính, file manifest và cấu hình runtime (package.json, pyproject, requirements, Dockerfile, compose, .env.example, scripts), dấu hiệu workload Linux/container/GPU, và ghi nhận các file quan trọng kèm dòng nếu có. Không cần phân tích toàn bộ mã nguồn; báo cáo ngắn gọn theo: dự án, runtime/dependency, dịch vụ, dữ liệu/volume, mức phù hợp với WSL2, điểm cần kiểm tra thêm. Nếu có file bí mật thì không in nội dung giá trị, chỉ nêu tên/loại. Chỉ đọc, không chỉnh sửa.",
  "subagent_type": "Explore",
  "mode": "default",
  "run_in_background": false,
  "name": "explore-lab",
  "team_name": "",
  "isolation": "default"
}
```

**Response:**

Đã khảo sát chỉ đọc. Workspace `D:\Lab` hiện chỉ có một file HTML, chưa có source code hay cấu trúc dự án thực thi.

**Cấu trúc / dự án**
- Không có thư mục con; chỉ có `D:\Lab\ha-lb-security-lab.html:1`.
- Đây là tài liệu thiết kế lab v4.2, không phải repository đã triển khai.
- Kiến trúc mô tả 12 VM trên máy Hùng, 6 vmnet private, máy Bảo chỉ làm control plane từ xa: `D:\Lab\ha-lb-security-lab.html:77`.
- Các VM dự kiến: `opns1/2`, `lb1/2`, `web1/2`, `pg1/2`, `obs`, `ca`, `attacker`, `sensor`: `D:\Lab\ha-lb-security-lab.html:82`.

**Runtime / dependency**
- Không tìm thấy manifest hoặc cấu hình thực tế: `package.json`, `pyproject.toml`, `requirements*.txt`, `Dockerfile`, Compose, `.env.example`, `Makefile`, `ansible.cfg`, `go.mod`, `Cargo.toml` đều chưa tồn tại trong workspace.
- Runtime được mô tả trong tài liệu:
  - Host Windows + VMware Workstation Pro, OpenSSH Server, Tailscale.
  - WSL2 + Ansible + Git/CI trên máy Bảo: `D:\Lab\ha-lb-security-lab.html:79`, `D:\Lab\ha-lb-security-lab.html:89`.
  - Debian 12 làm template cho các VM Linux: `D:\Lab\ha-lb-security-lab.html:511`.
- Dependency/dịch vụ dự kiến gồm OPNsense, Suricata, HAProxy, Keepalived, Apache/mod_security2, PostgreSQL 16, repmgr, pgBackRest, rsyslog/Loki, Prometheus/Grafana, Zeek, tcpdump và step-ca: `D:\Lab\ha-lb-security-lab.html:304`, `D:\Lab\ha-lb-security-lab.html:314`, `D:\Lab\ha-lb-security-lab.html:322`, `D:\Lab\ha-lb-security-lab.html:330`.

**Dịch vụ / workload**
- Firewall perimeter: 2 OPNsense, CARP, pfsync, cfgsync, 5 vùng mạng: `D:\Lab\ha-lb-security-lab.html:57`, `D:\Lab\ha-lb-security-lab.html:207`.
- IPS inline Suricata qua NFQUEUE trên WAN/DMZ, WAF CRS trên Apache: `D:\Lab\ha-lb-security-lab.html:304`.
- Load balancer HAProxy ×2 với TLS, mTLS, health check và Keepalived VIP: `D:\Lab\ha-lb-security-lab.html:314`.
- Web/app ×2, session lưu PostgreSQL; PostgreSQL ×2 streaming replication, DB VIP, promote/fencing và PITR: `D:\Lab\ha-lb-security-lab.html:318`, `D:\Lab\ha-lb-security-lab.html:322`.
- Quan sát tập trung qua syslog/Loki, Prometheus/Grafana và exporter: `D:\Lab\ha-lb-security-lab.html:330`.
- Workload Linux/container/GPU:
  - Có dấu hiệu workload Linux/VM mạnh.
  - Không thấy Docker, Podman, Kubernetes, container image/runtime, CUDA, NVIDIA hoặc ROCm.
  - Không có cấu hình GPU passthrough.

**Dữ liệu / volume / lưu trữ**
- PostgreSQL có WAL archive, full/incremental backup và PITR qua pgBackRest.
- Repository backup dự kiến đặt trên `obs` qua SSH hoặc NFS: `D:\Lab\ha-lb-security-lab.html:324`.
- OPNsense cần backup `config.xml` có mã hóa; VMware dùng snapshot `clean`, `green`, `before-*`, `IPS-off`: `D:\Lab\ha-lb-security-lab.html:197`, `D:\Lab\ha-lb-security-lab.html:291`.
- Chưa có volume mapping, mount point, filesystem layout hoặc policy retention thực tế.
- Không có Docker volume/Compose volume nào để kiểm tra.

**Mức phù hợp với WSL2**
- Phù hợp cao cho vai trò control plane: Ansible, Git/CI, SSH ProxyJump, script kiểm thử và trình duyệt truy cập Grafana/Prometheus qua port-forward: `D:\Lab\ha-lb-security-lab.html:117`, `D:\Lab\ha-lb-security-lab.html:208`.
- Không nên xem WSL2 là nền tảng thay thế cho phần lab chính; thiết kế phụ thuộc VMware Workstation, nhiều vNIC/vmnet, multicast CARP/Keepalived, pfsync và promiscuous capture.
- Cần kiểm tra thực tế WSL2 → Windows OpenSSH → VMware host → từng VM; tài liệu chủ trương không dùng route advertisement hoặc IP forwarding: `D:\Lab\ha-lb-security-lab.html:159`.
- Tài nguyên dự kiến khoảng 17 GB RAM khi bật đủ VM, trên host 32 GB: `D:\Lab\ha-lb-security-lab.html:85`. Đây là mức sát, cần chừa RAM cho Windows, VMware và WSL2.

**File nhạy cảm**
- Không tìm thấy file `.env`, secrets, key, certificate hoặc credential thực tế.
- HTML có placeholder/tên biến như `api_key`, `api_secret` và thông tin topology, IP nội bộ, username SSH; không thấy giá trị bí mật thực tế: `D:\Lab\ha-lb-security-lab.html:393`.
- Không in lại các thông tin vận hành nhạy cảm ngoài mức cần thiết.

**Điểm cần kiểm tra thêm**
- Tạo repository thực tế và pin phiên bản cho Ansible, OPNsense API, Debian, PostgreSQL, Suricata, HAProxy và các exporter; hiện chỉ có tài liệu.
- Xác nhận endpoint API OPNsense đúng với phiên bản cài đặt trước khi viết renderer: `D:\Lab\ha-lb-security-lab.html:414`.
- Kiểm chứng VMware có hỗ trợ ổn định CARP/pfsync/VRRP multicast, vmnet isolation và sensor promiscuous capture.
- Quyết định rõ IPS fail-open hay fail-closed: tài liệu có chỗ ghi “test fail-open”, nhưng NFR và phần test yêu cầu fail-closed; `D:\Lab\ha-lb-security-lab.html:59`, `D:\Lab\ha-lb-security-lab.html:249`, `D:\Lab\ha-lb-security-lab.html:436`.
- Làm rõ mức đáp ứng NFR-13: tài liệu thừa nhận `obs`, `ca`, `attacker`, `sensor` cùng nằm trên máy Hùng trong v4.2, nên chỉ đạt phân tách logic chứ không phải độc lập vật lý: `D:\Lab\ha-lb-security-lab.html:43`, `D:\Lab\ha-lb-security-lab.html:190`.
- Bổ sung kế hoạch quản lý secret, certificate, backup encryption key và quyền truy cập; hiện mới có quy ước `.gitignore` dự kiến: `D:\Lab\ha-lb-security-lab.html:527`.



> '**/*.{sh,py,ps1,psm1,js,ts,json,toml,ini,cfg,conf,env}' within ./

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe --status && printf '\\n--- WSL VERSION ---\\n' && wsl.exe --version && printf '\\n--- DISTROS ---\\n' && wsl.exe --list --verbose",
  "description": "Kiểm tra trạng thái phiên bản và distro WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

[Binary output: 894 bytes]

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command \"Write-Output '--- COMPUTER ---'; Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,TotalPhysicalMemory; Write-Output '--- CPU ---'; Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed; Write-Output '--- OS ---'; Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,FreePhysicalMemory,LastBootUpTime; Write-Output '--- GPU ---'; Get-CimInstance Win32_VideoController | Select-Object Name,AdapterRAM,DriverVersion; Write-Output '--- DISKS ---'; Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter,FileSystem,Size,SizeRemaining,HealthStatus\"",
  "description": "Kiểm tra CPU RAM GPU và dung lượng ổ đĩa",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- COMPUTER ---

Manufacturer Model          TotalPhysicalMemory
------------ -----          -------------------
Acer         Nitro AN515-58         34049417216
--- CPU ---
                                               
--- OS ---
                                               
--- GPU ---
                                               
                                               
                                               
                                               
--- DISKS ---

#### Tool: Bash

**Input:**

```json
{
  "command": "if [ -f 'C:/Users/Administrator/.wslconfig' ]; then printf '%s\\n' '--- .wslconfig exists ---'; wc -l 'C:/Users/Administrator/.wslconfig'; else printf '%s\\n' '--- .wslconfig not found ---'; fi; if command -v nvidia-smi >/dev/null 2>&1; then printf '%s\\n' '--- NVIDIA SMI ---'; nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader; else printf '%s\\n' '--- nvidia-smi unavailable ---'; fi",
  "description": "Kiểm tra cấu hình WSL và khả năng GPU NVIDIA",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- .wslconfig exists ---
31 C:/Users/Administrator/.wslconfig
--- NVIDIA SMI ---
NVIDIA GeForce RTX 3050 Laptop GPU, 4096 MiB, 617.14

[hook: SubagentStart] succeeded (exit 0)

#### Thinking

**Planning read-only file exploration****Enumerating root directory with Bash ls**

#### Tool: Bash

**Input:**

```json
{
  "command": "ls -la",
  "description": "List workspace root entries",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

total 196
drwxr-xr-x 1 Administrator 197121     0 Nov  7 10:04 .
drwxr-xr-x 1 Administrator 197121     0 Nov  6 09:50 ..
-rw-r--r-- 1 Administrator 197121 67298 Nov  7 09:50 ha-lb-security-lab.html

#### Thinking

**Inspecting single HTML file for report**

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 1,
  "limit": 4000,
  "pages": ""
}
```

**Response:**

1	<!DOCTYPE html>
2	<html lang="vi">
3	<head>
4	<meta charset="UTF-8">
5	<title>Đề tài Lab v4.2 — Firewall &amp; Security-First, 2 tuần, 1 máy host + Tailscale</title>
6	<style>
7	    body { font-family: "Times New Roman", Arial, sans-serif; line-height: 1.6; margin: 40px; color: #111; max-width: 1140px; }
8	    h1 { text-align: center; font-size: 22px; text-transform: uppercase; }
9	    h2 { font-size: 18px; margin-top: 30px; border-bottom: 2px solid #333; padding-bottom: 4px; }
10	    h3 { font-size: 16px; margin-top: 20px; }
11	    table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 14px; }
12	    th, td { border: 1px solid #000; padding: 7px 8px; text-align: left; vertical-align: top; }
13	    th { background-color: #f2f2f2; }
14	    pre { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; overflow-x: auto; font-family: Consolas, monospace; font-size: 12.5px; }
15	    code { background: #eee; padding: 1px 4px; font-family: Consolas, monospace; font-size: 12.5px; }
16	    .center { text-align: center; }
17	    .b45 { background: #8b1a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
18	    .b4  { background: #b4531a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
19	    .b3  { background: #7a6a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
20	    .note { background: #fff8e1; border-left: 4px solid #d4a017; padding: 10px 14px; margin: 12px 0; }
21	    .kpi { background: #eef4fb; border-left: 4px solid #2b5f8a; padding: 10px 14px; margin: 12px 0; }
22	    .stop { background: #fdecec; border-left: 4px solid #a33; padding: 10px 14px; margin: 12px 0; }
23	    .ok { background: #eaf5ea; border-left: 4px solid #2a7; padding: 10px 14px; margin: 12px 0; }
24	    ul, ol { margin-top: 6px; } li { margin-bottom: 4px; }
25	</style>
26	</head>
27	<body>
28	<h1>ĐỀ TÀI LAB v4.2 — FIREWALL &amp; SECURITY-FIRST</h1>
29	<p class="center"><strong>
30	Perimeter nhiều vùng có HA thật, IPS inline, chính sách dạng mã nguồn,
31	dịch vụ được bảo vệ nhiều lớp — vận hành trên một máy host, điều khiển từ máy thứ hai qua Tailscale
32	</strong></p>
33	
34	<div class="kpi">
35	<strong>v4.2 = 115.5 giờ, 12 VM (tất cả trên máy Hùng), Hùng 60h / Bảo 55.5h, lịch 14 ngày, chi phí phần cứng 0 đồng.</strong>
36	115.5h = <strong>82%</strong> quỹ 140 giờ (2 người × 10 ngày × 7 giờ) → còn 24.5 giờ đệm.
37	Độ khó trung bình <strong>≈ 4.35/5</strong>, cụm tường lửa–an ninh đạt <strong>4.5–4.8</strong>.
38	<br><br>
39	<strong>Thay đổi so với v4.1:</strong> bỏ toàn bộ dây cáp và USB-Ethernet adapter. Hai laptop nối nhau qua
40	<strong>Tailscale</strong>; máy Bảo làm việc từ xa bằng <code>ProxyJump</code> + port-forward —
41	<em>không</em> advertise route, <em>không</em> bật IP forwarding trên Windows. Được: GĐ0 giảm 12h xuống 8.5h,
42	toàn bộ lớp lỗi ghép nối giữa 2 máy biến mất, đường quản trị không còn chạm vào chính sách perimeter.
43	Mất: <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> nằm trong máy Hùng nên
44	attack validation giảm 4.6 xuống 4.2, NFR-13 chỉ còn đúng theo nghĩa phân tách vùng, và tiến độ của Bảo
45	phụ thuộc việc máy Hùng có bật hay không.
46	<br><br>
47	<strong>Bảy điều bắt buộc lưu ý khi dùng Tailscale nằm ở mục 2.4.</strong> Hai điều dễ chết người nhất:
48	mặc định Tailscale <em>hết hạn key sau 180 ngày</em>, và đừng cố <code>--advertise-routes</code> + IP forwarding trên Windows.
49	<br><br>
50	So với v3: chiều sâu dịch vụ bị giảm có chủ đích (bỏ drain/reload 0 lỗi, bỏ Redis session, bỏ rolling deploy,
51	bỏ auto-failover DB phức tạp) để dồn ngân sách vào 4 thứ: <em>perimeter HA, IPS inline, policy-as-code, kiểm chứng tấn công</em>.
52	</div>
53	
54	<h2>1. Thay đổi so với v3</h2>
55	<table>
56	    <tr><th>Chủ đề</th><th>v3</th><th>v4</th><th>Lý do</th></tr>
57	    <tr><td>Thiết bị biên</td><td>1× Debian + nftables</td><td><strong>2× OPNsense, CARP + pfsync + cfgsync</strong>, 5 vùng</td>
58	        <td>Đánh mạnh tường lửa thì phải có thiết bị biên thật, có HA, có state sync</td></tr>
59	    <tr><td>IPS</td><td>Suricata pcap / alert</td><td><strong>Suricata inline NFQUEUE (blocking)</strong> + test fail-open</td>
60	        <td>Chặn thật ở perimeter, không chỉ phát hiện</td></tr>
61	    <tr><td>Chính sách</td><td>File nftables trong Git</td><td><strong>YAML khai báo → render qua API OPNsense → apply không gián đoạn</strong></td>
62	        <td>Điểm khó nhất và cũng là điểm ăn tiền nhất của phần firewall</td></tr>
63	    <tr><td>Rate limit</td><td>Ở HAProxy (stick-table)</td><td><strong>Dịch chuyển xuống firewall</strong> (max states / alias + policy)</td>
64	        <td>Đúng chủ đề hơn: chống flood là việc của perimeter</td></tr>
65	    <tr><td>Góc nhìn tấn công</td><td>Client trong cùng host</td><td><strong>Attacker + sensor trên vmnet WAN riêng</strong> (v4.2: không còn ở máy thứ 2)</td>
66	        <td>Firewall chỉ có ý nghĩa khi bị đánh từ ngoài; sensor cho bằng chứng độc lập</td></tr>
67	    <tr><td>Hypervisor</td><td>VirtualBox + unicast hack</td><td><strong>VMware Workstation Pro</strong> (miễn phí cá nhân)</td>
68	        <td>CARP/pfsync dùng multicast — vmnet của VMware xử lý được, VirtualBox thì không ổn định</td></tr>
69	    <tr><td>HAProxy</td><td>8 tính năng, 15.5h</td><td>4 tính năng, 7h (TLS, mTLS, healthcheck, VIP)</td>
70	        <td>Nhượng giờ cho firewall</td></tr>
71	    <tr><td>DB</td><td>repmgr automatic failover</td><td>Streaming + <strong>promote có script + DB VIP</strong>, giữ PITR</td>
72	        <td>Giảm 3h, độ khó 4.5→4.2, vẫn chứng minh RPO=0</td></tr>
73	    <tr><td>Session</td><td>Redis + sticky cookie</td><td>Session trong DB, không sticky</td>
74	        <td>Giảm 2h; khai báo thẳng là trade-off trong báo cáo</td></tr>
75	</table>
76	
77	<h2>2. Hạ tầng: một máy host + Tailscale control plane</h2>
78	<table>
79	    <tr><th></th><th>Máy HÙNG — i5-12500H, 32 GB</th><th>Máy BẢO — i7-11800H, 16 GB</th></tr>
80	    <tr><td>Vai trò</td><td><strong>Toàn bộ lab</strong>: 12 VM, mọi vùng mạng</td>
81	        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
82	    <tr><td>VM</td>
83	        <td>opns1, opns2, lb1, lb2, web1, web2, pg1, pg2, obs, ca, attacker, sensor</td>
84	        <td><strong>0 VM</strong></td></tr>
85	    <tr><td>Ram</td>
86	        <td>2 + 2 + 0.5 + 0.5 + 1 + 1 + 1.5 + 1.5 + 2.5 + 0.5 + 2 + 1.5 = <strong>17 GB</strong> khi bật đủ;<br>
87	            steady state ~13.5 GB (attacker + sensor chỉ bật khi test)</td>
88	        <td>~2 GB cho WSL2 + Tailscale + trình duyệt</td></tr>
89	    <tr><td>Phần mềm cần cài</td><td>VMware Workstation Pro, OpenSSH Server, Tailscale</td><td>Tailscale, WSL2 + Ansible, Git</td></tr>
90	    <tr><td>Chi phí thêm</td><td colspan="2"><strong>0 đồng</strong> — không cáp, không USB-Ethernet adapter, không switch</td></tr>
91	</table>
92	
93	<h3>2.1 Bố trí vmnet (không còn bridged)</h3>
94	<pre>
95	MÁY HÙNG — 6 vmnet, TẤT CẢ là private/host-only trong host, không cái nào ra mạng vật lý:
96	
97	  vmnet-wan      10.0.0.0/24     : opns1 eth0 .1, opns2 eth0 .2, CARP VIP .100,
98	                                  attacker .20, sensor .21        ← "Internet" giả lập
99	  vmnet-sync     192.168.50.0/24 : opns1 ↔ opns2 (pfsync + cfgsync)
100	  vmnet-dmzfront 192.168.20.0/24 : opns eth1, lb1 .10, lb2 .11, Keepalived VIP .100
101	  vmnet-dmzapp   192.168.21.0/24 : opns eth2, web1 .21, web2 .22
102	  vmnet-trusted  192.168.30.0/24 : opns eth3, pg1 .11, pg2 .12, DB VIP .100
103	  vmnet-mgmt     192.168.99.0/24 : opns eth4, GUI VIP .100, obs .30, ca .31
104	
105	MÁY BẢO — không có vmnet nào tham gia lab:
106	  Tailscale 100.64.x.x  ──ssh──►  host Windows của Hùng (100.64.x.x)
107	                                    │ host có adapter trên MỖI vmnet ở trên
108	                                    └─► tới được mọi VM mà không cần route
109	</pre>
110	<div class="kpi">
111	<strong>Điểm làm cho phương án này chạy được:</strong> ProxyJump không định tuyến gói tin — nó mở một kết nối TCP
112	<em>từ host của Hùng</em> tới VM đích. Vì host OS vốn đã nằm trên từng vmnet (adapter VMnet1/VMnet8 tương ứng),
113	nó tới được mọi VM mà không cần advertise route, không cần IP forwarding, không cần RRAS. Đây là lý do bỏ được cáp
114	mà không phải đánh đổi cấu hình lab.
115	</div>
116	
117	<h3>2.2 Quyền truy cập từ máy Bảo</h3>
118	<pre>
119	# Liệt kê VM đang chạy và bật một VM từ xa
120	ssh hung@100.64.x.x '"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list'
121	ssh hung@100.64.x.x '"...\vmrun.exe" start "D:\lab\lb1\lb1.vmx" nogui'
122	
123	# Vào VM bất kỳ — dùng host làm jump hop
124	ssh -J hung@100.64.x.x ops@192.168.20.10          # lb1
125	ssh -J hung@100.64.x.x ops@192.168.30.11          # pg1
126	
127	# ansible.cfg — một dòng cho toàn bộ playbook
128	[ssh_connection]
129	ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ProxyJump=hung@100.64.x.x
130	
131	# Giao diện đồ hoạ: port-forward, không cần route
132	ssh -L 3000:192.168.99.30:3000 hung@100.64.x.x    # Grafana   → http://localhost:3000
133	ssh -L 9090:192.168.99.30:9090 hung@100.64.x.x    # Prometheus
134	ssh -L 8443:192.168.99.100:443  hung@100.64.x.x   # GUI OPNsense (CARP VIP vùng MGMT)
135	ssh -L 8404:192.168.20.10:8404  hung@100.64.x.x   # HAProxy stats
136	</pre>
137	<p>
138	<strong>Bastion vẫn tồn tại trong lab</strong> (<code>obs</code>, 192.168.99.30, NIC MGMT). Bạn <em>không</em> đi qua nó để vào
139	lab nữa, nhưng nó vẫn là node mà POL-005 ("SSH chỉ từ MGMT") áp dụng, và vẫn là nơi chạy <code>repmgr witness</code> +
140	syslog receiver. Nhờ vậy ma trận chính sách không bị rỗng ở dòng SSH — nếu bỏ luôn bastion thì T-07 mất một nửa ý nghĩa.
141	</p>
142	
143	<h3>2.3 Thiết kế đã loại: vì sao trước đây cần cáp</h3>
144	<div class="stop">
145	Phiên bản v4.1 dùng 2 sợi cáp để <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> chạy trên máy Bảo.
146	Lý do phải dùng L2 thật: <strong>Tailscale không tạo broadcast domain chung giữa hai máy</strong> (mesh các <code>/32</code>),
147	nên VM trên máy Bảo không thể nằm cùng segment WAN với <code>opns1</code>.
148	<br><br>
149	Và đây là lý do <em>không được</em> nhân tiện đặt DMZ-FRONT lên cùng L2 với WAN — attacker đi vòng qua perimeter:
150	<pre>
151	ip route add 192.168.20.0/24 dev eth0
152	arping -I eth0 192.168.20.100          # lấy được MAC của VIP
153	curl -k --resolve lab:443:192.168.20.100 https://lab/    # KHÔNG đi qua firewall
154	</pre>
155	Giữ lại đoạn này trong báo cáo như một <em>rejected design</em>: nó giải thích vì sao DMZ thật phải là VLAN/L2 riêng,
156	và vì sao ta chọn "mọi thứ trong một host, các vùng là vmnet tách biệt" thay vì "hai máy nối cáp".
157	</div>
158	
159	<h3>2.4 Bảy điều bắt buộc lưu ý khi dùng Tailscale</h3>
160	<table>
161	    <tr><th>#</th><th>Lưu ý</th><th>Chi tiết / lệnh</th></tr>
162	    <tr><td>1</td><td><strong>Tắt hạn key</strong></td>
163	        <td>Mặc định Tailscale hết hạn key sau 180 ngày. Hai máy chạy từ trước kỳ học → <em>giữa kỳ bị đá khỏi tailnet</em>,
164	        và thông báo rất khó đoán. <code>tailscale set --expiry=0</code> trên cả hai máy, ghi vào <code>docs/interfaces.md</code>.</td></tr>
165	    <tr><td>2</td><td><strong>Không advertise routes</strong></td>
166	        <td>Đừng chạy <code>--advertise-routes=192.168.20.0/24,...</code> và đừng cố bật IP forwarding trên Windows.
167	        ProxyJump + <code>-L</code> đã đủ mọi nhu cầu. Đây là hố thời gian lớn nhất của phương án này.</td></tr>
168	    <tr><td>3</td><td><strong>OpenSSH Server, không phải Tailscale SSH, cho vai jump</strong></td>
169	        <td>Tailscale SSH tiện để login nhưng hỗ trợ <code>-W</code>/ProxyJump không ổn định. Cài <code>sshd</code> Windows,
170	        StartupType Automatic, key-only.</td></tr>
171	    <tr><td>4</td><td><strong>Biết mình đang direct hay DERP</strong></td>
172	        <td>Cùng một LAN → kết nối trực tiếp, độ trễ &lt;1 ms, gần bằng cáp. Khác mạng → có thể đi qua DERP (rẽ qua Internet),
173	        latency nhảy. Trước mỗi phép đo timing: <code>tailscale status | grep &lt;bạn&gt;</code>, và ghi <code>direct</code>/<code>DERP</code> vào biên bản test.</td></tr>
174	    <tr><td>5</td><td><strong>Mất Internet = mất điều khiển từ xa</strong></td>
175	        <td>Không có fallback nào ngoài việc sang máy Hùng làm trực tiếp. Vì vậy: việc quan trọng luôn có lệnh thủ công tương đương,
176	        và không có việc nào chỉ chạy được từ máy Bảo.</td></tr>
177	    <tr><td>6</td><td><strong>Máy Hùng là điểm nghẽn tiến độ</strong></td>
178	        <td>Hùng tắt máy thì Bảo chỉ viết code/báo cáo. Quy ước: thông báo trước 1 ngày khi cần lab bật; phần việc của Bảo trong
179	        khung không có lab chuyển sang B04/B18 (policy YAML, báo cáo).</td></tr>
180	    <tr><td>7</td><td><strong>Đường quản trị không qua firewall — phải nói rõ</strong></td>
181	        <td>Đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter.
182	        Ghi thẳng vào báo cáo (B10) thay vì để giám khảo phát hiện; nếu không, nó trông như một lỗ hổng bạn không biết mình có.</td></tr>
183	</table>
184	
185	<h3>2.5 Cái được và cái mất so với phương án 2 cáp</h3>
186	<table>
187	    <tr><th></th><th>v4.1 — 2 cáp</th><th>v4.2 — Tailscale</th></tr>
188	    <tr><td>Chi phí phần cứng</td><td>2 USB-Ethernet adapter + 2 cáp (~500k)</td><td><strong>0đ</strong></td></tr>
189	    <tr><td>Giờ GĐ0</td><td>12h</td><td><strong>8.5h</strong></td></tr>
190	    <tr><td>Việc của Bảo chạy độc lập</td><td>~20h (obs/ca/attacker trên máy mình)</td><td>~10h (chỉ code + báo cáo; mọi test cần lab bật)</td></tr>
191	    <tr><td>Độ khó attack validation</td><td>4.6 (bằng chứng từ host vật lý khác)</td><td>4.2 (bằng chứng từ vmnet riêng, cùng host)</td></tr>
192	    <tr><td>NFR-13 giám sát ngoài vùng bảo vệ</td><td>Đúng nghĩa vật lý</td><td>Chỉ đúng nghĩa <em>logic</em> — obs ở vùng MGMT riêng, không node DMZ/TRUSTED nào ghi được</td></tr>
193	    <tr><td>Lỗi ghép nối giữa 2 máy</td><td>Có (adapter, driver, bridged Wi-Fi, client isolation)</td><td><strong>Không còn</strong></td></tr>
194	    <tr><td>Tổng giờ</td><td>120h</td><td><strong>115.5h</strong> (82% quỹ 140h)</td></tr>
195	</table>
196	
197	<h3>2.6 Quy ước vận hành</h3>
198	<ul>
199	    <li>Máy Hùng: Power plan High performance, <em>never sleep</em> khi cắm điện; <code>sshd</code> automatic; Tailscale autostart.</li>
200	    <li>Không ai tự <code>poweroff</code> VM của người kia. Lệnh tắt cả lab là lệnh chung, báo trước. Ghi rõ trong <code>CONTRIBUTING.md</code>.</li>
201	    <li>NTP: một source chung cho 12 VM + 2 host OS. PITR và đối chiếu log đa nguồn đều theo timestamp.</li>
202	    <li>Snapshot: <code>clean</code> (ngày 1), <code>green</code> (cuối mỗi ngày), <code>before-&lt;T-xx&gt;</code> (trước mỗi test phá),
203	        <code>IPS-off</code> (trước khi bật inline IPS).</li>
204	    <li>Việc nào cần bật attacker/sensor thì bật, xong thì tắt — tiết kiệm 3.5 GB RAM và tránh Suricata chạy nền làm nhiễu phép đo.</li>
205	</ul>
206	
207	<h2>3. Kiến trúc 5 vùng</h2>
208	<pre>
209	   MÁY BẢO (0 VM)                                MÁY HÙNG (12 VM, 6 vmnet riêng)
210	  Tailscale 100.64.x ──ssh / ProxyJump──► host Windows + WSL2 Ansible + Git/CI
211	  browser: Grafana, GUI OPNsense (qua ssh -L)
212	
213	   vmnet-wan  10.0.0.0/24 : attacker .20, sensor .21, opns1 .1 / opns2 .2,
214	                            CARP VIP .100  → DNAT 443 về LB VIP
215	   vmnet-sync 192.168.50.0/24 : opns1 ↔ opns2  (pfsync + cfgsync, không ra ngoài)
216	        ┌─────────┬──────────────┬────────────┬────────────────┐
217	   DMZ-FRONT   DMZ-APP        TRUSTED       MGMT
218	   192.168.20  192.168.21     192.168.30    192.168.99
219	   lb1 .10     web1 .21       pg1 .11       opns .1/.2, GUI VIP .100
220	   lb2 .11     web2 .22       pg2 .12       obs .30 (bastion + witness), ca .31
221	   VIP .100    (app+CRS)      DB VIP .100
222	   (Keepalived)               (repmgr + PITR)
223	        IPS inline: WAN + DMZ-FRONT + DMZ-APP
224	</pre>
225	<table>
226	    <tr><th>Vùng</th><th>Dải</th><th>Node</th><th>Nằm ở</th><th>Chính sách mặc định</th><th>IPS</th></tr>
227	    <tr><td>WAN</td><td>10.0.0.0/24</td><td>opns1/2 WAN, CARP .100, attacker .20, sensor .21</td><td>Máy Hùng (vmnet-wan)</td>
228	        <td>Chỉ DNAT 443 → LB VIP + SSH từ <code>ADMIN_SRC</code> → bastion; mọi inbound khác drop</td><td>Có (inline)</td></tr>
229	    <tr><td>DMZ-FRONT</td><td>192.168.20.0/24</td><td>lb1 .10, lb2 .11, VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
230	        <td>lb chỉ được gọi web:8443 và NTP/MGMT theo whitelist</td><td>Có (inline)</td></tr>
231	    <tr><td>DMZ-APP</td><td>192.168.21.0/24</td><td>web1 .21, web2 .22</td><td>Máy Hùng (vmnet riêng)</td>
232	        <td>Chỉ được gọi TRUSTED:5432; <strong>cấm egress ra WAN</strong></td><td>Có (inline)</td></tr>
233	    <tr><td>TRUSTED</td><td>192.168.30.0/24</td><td>pg1 .11, pg2 .12, DB VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
234	        <td>Chỉ nhận từ alias <code>APP_NODES</code>; cấm ra WAN</td><td>Không (giữ hiệu năng)</td></tr>
235	    <tr><td>MGMT</td><td>192.168.99.0/24</td><td>opns .1/.2, GUI VIP .100, obs .30, ca .31</td><td>Máy Hùng (vmnet-mgmt)</td>
236	        <td>GUI + SSH chỉ từ MGMT/bastion; obs được phép scrape các vùng</td><td>Không</td></tr>
237	</table>
238	<div class="note">
239	<strong>Hai segment xuyên máy là WAN và MGMT — và chỉ hai cái đó.</strong> Nguyên tắc: một segment chỉ được trải
240	qua 2 máy khi nó <em>không</em> chứa node nào mà attacker có thể lợi dụng để đi vòng qua perimeter. WAN là vùng
241	không tin cậy (mọi thứ đi qua nó đều bị kiểm), MGMT là vùng quản trị có kiểm soát (bastion + <code>ADMIN_SRC</code>).
242	DMZ-FRONT/DMZ-APP/TRUSTED bắt buộc ở lại trong một host — xem 2.4.
243	</div>
244	
245	<h2>4. Ràng buộc phi chức năng (14 điều, firewall-first)</h2>
246	<table>
247	    <tr><th>Mã</th><th>Ràng buộc</th><th>Ngưỡng phải đạt</th></tr>
248	    <tr><td>NFR-01</td><td>CARP failover</td><td>Đổi master ≤ 5 s; <strong>session TCP đang mở không đứt</strong> (pfsync hoạt động) — đo bằng <code>iperf3</code> + <code>ssh</code> đang chạy</td></tr>
249	    <tr><td>NFR-02</td><td>Áp dụng chính sách dưới tải</td><td>Thêm/sửa rule qua API: 0 gián đoạn, 0 lỗi 5xx, không cắt state đang có</td></tr>
250	    <tr><td>NFR-03</td><td>Default-deny tuyệt đối</td><td>Mọi permit phải tham chiếu <strong>alias</strong>, không hardcode IP đơn; 24 combo (zone,dst,port) kiểm tự động, khớp 100%</td></tr>
251	    <tr><td>NFR-04</td><td>IPS fail-closed</td><td>Khi Suricata/NFQUEUE chết, traffic <strong>không</strong> được flow-through im lặng; phải có alert + test chứng minh hành vi đã chọn</td></tr>
252	    <tr><td>NFR-05</td><td>Bằng chứng cho mọi rule</td><td>Mỗi rule có <code>POLICY-ID</code> + counter; báo cáo nêu được rule nào đã được kích hoạt bởi kịch bản nào</td></tr>
253	    <tr><td>NFR-06</td><td>Chống flood ở perimeter</td><td>State table limit / max src conn: SYN flood 50k pkt/s không làm sập dịch vụ, VIP vẫn nổi</td></tr>
254	    <tr><td>NFR-07</td><td>Không có egress</td><td>DMZ-APP và TRUSTED không tự ra WAN được (chặn C2/exfil); kiểm bằng reverse shell mô phỏng</td></tr>
255	    <tr><td>NFR-08</td><td>Log tập trung + tương quan</td><td>Firewall + IPS + WAF + app về obs, giữ ≥ 7 ngày; tái hiện được 1 chuỗi tấn công hoàn chỉnh bằng log</td></tr>
256	    <tr><td>NFR-09</td><td>Bảo mật truyền thông</td><td>mTLS LB→web; GUI/Giám sát chỉ qua TLS; không plaintext credential</td></tr>
257	    <tr><td>NFR-10</td><td>Khôi phục dữ liệu</td><td>PITR tới timestamp chỉ định, verify bản ghi; RPO = 0 khi mất DB primary</td></tr>
258	    <tr><td>NFR-11</td><td>Hardening thiết bị biên</td><td>Tắt service thừa, GUI TLS + khoá root shell, NTP, backup config có mã hoá, bogon + private-network + anti-spoof bật</td></tr>
259	    <tr><td>NFR-12</td><td>IaC</td><td>Toàn bộ chính sách + config dịch vụ là mã nguồn; rebuild ≤ 30 phút; <code>make check</code> xanh; drift = 0</td></tr>
260	    <tr><td>NFR-13</td><td>Mặt phẳng giám sát ngoài vùng bảo vệ</td><td><code>obs</code>, <code>ca</code>, <code>sensor</code> chạy trên máy khác và không có node nào bị compromise xoá/sửa được bằng chứng về chính nó; kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert</td></tr>
261	    <tr><td>NFR-14</td><td>Không có đường vòng L2</td><td>Không tồn tại segment nào vừa chứa attacker vừa chứa node dịch vụ được bảo vệ; chứng minh bằng <code>arping</code> thất bại từ attacker tới DMZ-FRONT</td></tr>
262	</table>
263	
264	<h2>5. Độ khó theo hạng mục</h2>
265	<table>
266	    <tr><th>Hạng mục</th><th>Độ khó</th><th>Vì sao ở mức đó</th></tr>
267	    <tr><td>OPNsense ×2 + CARP + pfsync + cfgsync</td><td><span class="b45">4.8</span></td><td>HA tầng 2 trên 5 vùng; pfsync giữ state; cfgsync phải không ghi đè tay; failover đo bằng session đang mở</td></tr>
268	    <tr><td>Policy-as-code (YAML → API → apply)</td><td><span class="b45">4.7</span></td><td>Thiết kế mô hình alias/zone + render + áp dụng không gián đoạn + validate 24 combo</td></tr>
269	    <tr><td>Suricata inline IPS + fail-closed</td><td><span class="b45">4.6</span></td><td>NFQUEUE blocking thật, tuning rule, và trả lời câu hỏi "IPS chết thì hệ thống mở hay đóng"</td></tr>
270	    <tr><td>Attack validation + sensor-side evidence</td><td><span class="b45">4.6</span></td><td>Đánh từ ngoài, đối chiếu log phòng thủ với bằng chứng tấn công, map MITRE</td></tr>
271	    <tr><td>Perimeter anti-flood (state limit)</td><td><span class="b45">4.5</span></td><td>Phải đo được state table, không làm sập lab, và giải thích giới hạn</td></tr>
272	    <tr><td>pgBackRest PITR</td><td><span class="b45">4.5</span></td><td>WAL archive + restore theo timestamp + verify dữ liệu</td></tr>
273	    <tr><td>Log correlation + alerting</td><td><span class="b4">4.4</span></td><td>4 nguồn log khác định dạng, tương quan theo thời gian + IP</td></tr>
274	    <tr><td>IaC + CI + rebuild</td><td><span class="b4">4.4</span></td><td>Idempotent trên cả thiết bị biên, drift detection</td></tr>
275	    <tr><td>DB failover + fencing + DB VIP</td><td><span class="b4">4.2</span></td><td>Promote có script, node cũ bị chặn không ghi được</td></tr>
276	    <tr><td>HAProxy + Keepalived VIP</td><td><span class="b4">4.2</span></td><td>TLS, mTLS, health check, VIP multicast</td></tr>
277	    <tr><td>WAF CRS blocking</td><td><span class="b4">4.2</span></td><td>Blocking + ParanoiaLevel 2 + đo false positive</td></tr>
278	    <tr><td>PKI / mTLS</td><td><span class="b4">4.0</span></td><td>CA nội bộ, cert server+client, rotation cơ bản</td></tr>
279	    <tr><td>Web tier + app</td><td><span class="b3">3.6</span></td><td>Đã giản lược (không Redis/rolling deploy) — đây là phần chủ động nhường giờ</td></tr>
280	    <tr><td colspan="2"><strong>TB toàn đề tài</strong></td><td><strong>≈ 4.35 / 5</strong> — cụm firewall–an ninh TB 4.6</td></tr>
281	</table>
282	
283	<h2>6. Phạm vi chi tiết theo 6 cụm</h2>
284	
285	<h3>Cụm A — Nền tảng biên (Hùng)</h3>
286	<ul>
287	    <li>2× OPNsense, mỗi con 5 vNIC; VMXNET3; <code>sync</code> là vmnet host-only riêng cho pfsync + cfgsync (không để pfsync chạy trên WAN).</li>
288	    <li>CARP: vhid duy nhất per zone, 1 con MASTER (advskew thấp), <code>preempt</code> tắt để tránh flap khi demo; theo dõi <code>sysctl net.inet.carp.preempt</code>, <code>ifconfig carp</code>.</li>
289	    <li><strong>pfsync state sync</strong>: bật sync trên mọi interface, kiểm bằng session dài (iperf3/ssh) sống sót qua failover.</li>
290	    <li><strong>cfgsync</strong>: tài khoản sync chỉ có quyền tối thiểu; test sửa tay trên backup → master không bị ghi đè im lặng, và ngược lại phải có cảnh báo drift.</li>
291	    <li>Hardening: GUI HTTPS với cert nội bộ, tắt HTTP, vô hiệu service không dùng, <code>Allow OPT1..</code> tắt, anti-spoofing bật, bogon + private networks, NTP từ MGMT, định kỳ backup <code>config.xml</code> có mã hoá.</li>
292	    <li>Chống flood: <code>states</code> limit, <code>max-src-conn</code>, <code>syncookies</code> (kiểm bằng hping3 từ attacker, ghi lại số state và ảnh hưởng tới VIP).</li>
293	</ul>
294	
295	<h3>Cụm B — Chính sách dạng mã nguồn (Bảo)</h3>
296	<ul>
297	    <li>Mô hình khai báo trong Git: <code>zones</code>, <code>aliases</code> (group objects: <code>APP_NODES</code>, <code>DB_VIP</code>, <code>MGMT_ALLOWED</code>), <code>services</code>, <code>rules[]</code> với <code>id: POL-xxx</code>, <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>.</li>
298	    <li>Renderer Ansible → gọi API OPNsense (alias add/set, rule_filter add/set, <code>apply</code> + <code>filter reload</code>) — reload không cắt state, đó là cơ sở của NFR-02. <em>Cần verify tên endpoint trên đúng phiên bản bạn cài; tài liệu API thay đổi theo release.</em></li>
299	    <li>Idempotency: chạy 2 lần ra cùng một rule set; xoá 1 rule trong YAML → rule biến mất trên thiết bị (không phải cộng dồn).</li>
300	    <li><strong>Policy validator</strong>: quét 24 combo (zone nguồn, đích, port) từ attacker/sensor/web/db, so với YAML, xuất CSV; đồng thời đọc counter của từng rule để chứng minh rule đã thực sự được đi qua.</li>
301	    <li>Drift check: <code>make drift</code> so trạng thái thiết bị với Git, khác biệt = fail CI.</li>
302	</ul>
303	
304	<h3>Cụm C — IPS, WAF và kiểm chứng tấn công</h3>
305	<ul>
306	    <li>Suricata inline trên WAN + DMZ-FRONT + DMZ-APP (OPNsense plugin, chế độ NFQUEUE, blocking), ruleset: emerging-threats + rule tự viết cho hành vi của lab.</li>
307	    <li>Test <strong>fail-closed</strong>: dừng dịch vụ Suricata khi đang có kết nối → xác nhận traffic bị chặn (không phải âm thầm flow-through) và có alert; ghi rõ lựa chọn thiết kế.</li>
308	    <li>CRS blocking trên Apache (mod_security2), ParanoiaLevel 2, file overrides trong Git kèm <code>Reason:</code>.</li>
309	    <li>Bộ tấn công từ <code>attacker</code> — 4 lớp trong harness (B14): (1) nmap/scan → IPS alert; (2) 30 payload web (SQLi/XSS/traversal) → WAF 403 + IPS; (3) SSH brute force → Fail2Ban + alias ban; (4) egress attempt từ web ra WAN → bị chặn. Lớp thứ 5 (SYN flood → state limit) thuộc H10 vì nó là việc của thiết bị biên.</li>
310	    <li><strong>Sensor</strong> (VM riêng trên vmnet-wan) chạy tcpdump + Zeek độc lập: với mỗi tấn công, đối chiếu "tôi đã gửi gì" và "hệ thống phòng thủ ghi nhận gì"; bảng lệch nhau là nội dung báo cáo có giá trị nhất.</li>
311	    <li>Map MITRE ATT&amp;CK: T1046 (scan), T1190 (exploit public app), T1110 (brute force), T1048/T1071 (egress/C2), T1562.110 (impair defenses — chính là test fail-closed).</li>
312	</ul>
313	
314	<h3>Cụm D — Tầng dịch vụ được bảo vệ (Bảo)</h3>
315	<ul>
316	    <li>HAProxy ×2: TLS termination, mTLS xuống web, health check <code>/healthz</code>, stats bind MGMT.</li>
317	    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
318	    <li>App 4 endpoint: <code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code> (ghi DB), <code>/session</code>; session lưu trong PostgreSQL (chứng minh app stateless mà không cần Redis).</li>
319	    <li>Web chỉ nhận kết nối có client cert; không truy cập Internet.</li>
320	</ul>
321	
322	<h3>Cụm E — Tầng dữ liệu + khôi phục (Hùng)</h3>
323	<ul>
324	    <li>PostgreSQL 16 ×2, streaming replication, <code>synchronous_commit = on</code>, <code>hostssl</code> + scram.</li>
325	    <li>Failover bằng script <code>promote.sh</code>: di chuyển <code>DB_VIP 192.168.30.100</code> sang standby + đẩy alias firewall cập nhật + <strong>fence</strong> node cũ (stop + rule chặn 5432 từ nó).</li>
326	    <li>App không đổi connection string (luôn trỏ DB_VIP) — đây là điểm khác biệt so với v3 và là thứ phải chứng minh được.</li>
327	    <li>pgBackRest: full + incremental + WAL archive lên obs (repo NFS/ssh), <strong>diễn tập PITR</strong> tới timestamp và verify 3 bản ghi mốc.</li>
328	</ul>
329	
330	<h3>Cụm F — Bằng chứng, quan sát, tự động hoá (Bảo)</h3>
331	<ul>
332	    <li>Remote syslog 3 nguồn từ OPNsense + web + db → obs (rsyslog → Loki); 3 dashboard Grafana với 4 panel chính: policy hit, IPS block, WAF block, state table.</li>
333	    <li><strong>Mặt phẳng giám sát nằm ngoài vùng bảo vệ</strong> (NFR-13): <code>obs</code>, <code>ca</code>, <code>sensor</code> nằm ở vùng MGMT/WAN riêng,
334	        nên không node nào trong vùng bị bảo vệ có khả năng xoá hoặc sửa bằng chứng về chính nó. Kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert.</li>
335	    <li>Prometheus: node_exporter, haproxy export, postgres_exporter; 6 alert: mất master CARP, IPS xuống, rule counter bất thường, 5xx &gt; 1%, DB leader đổi, PITR backup &gt; 24h chưa chạy.</li>
336	    <li>Ansible + <code>make check</code> (lint + <code>haproxy -c</code> + <code>apachectl configtest</code> + <code>suricata -T</code> + gitleaks) + <code>make drift</code>.</li>
337	    <li><code>run_matrix.sh</code> sinh CSV theo schema: <code>scenario,ts,host,detect_s,rto_s,req_total,err_5xx,err_conn,pass</code>.</li>
338	</ul>
339	
340	<h2>7. Cấu hình tham chiếu</h2>
341	
342	<h3>7.1 Mô hình chính sách khai báo (file nguồn duy nhất)</h3>
343	<pre>
344	# policy/zones.yml
345	zones:
346	  wan:       { net: 10.0.0.0/24,        iface: wan }
347	  dmz_front: { net: 192.168.20.0/24,    iface: opt1 }
348	  dmz_app:   { net: 192.168.21.0/24,    iface: opt2 }
349	  trusted:   { net: 192.168.30.0/24,    iface: opt3 }
350	  mgmt:      { net: 192.168.99.0/24,    iface: opt4 }
351	
352	aliases:
353	  LB_VIP:    { type: host,   items: [192.168.20.100] }
354	  APP_NODES: { type: network, items: [192.168.21.21/32, 192.168.21.22/32] }
355	  DB_VIP:    { type: host,   items: [192.168.30.100] }
356	  MGMT_ONLY: { type: network, items: [192.168.99.0/24] }
357	
358	rules:
359	  - id: POL-001
360	    desc: "Public HTTPS vào LB VIP"
361	    zone: wan -> dmz_front
362	    proto: tcp, dst: LB_VIP, dport: 443
363	    action: pass, log: true, test: T-07
364	    nat: { type: static-port-forward, to: 192.168.20.100:443 }
365	
366	  - id: POL-002
367	    desc: "Web truy cập DB, chỉ từ alias APP_NODES"
368	    zone: dmz_app -> trusted
369	    proto: tcp, src: APP_NODES, dst: DB_VIP, dport: 5432
370	    action: pass, log: true, test: T-07
371	
372	  - id: POL-003
373	    desc: "Cấm WAN vào DB (kiểm chứng deny)"
374	    zone: wan -> trusted
375	    proto: any, dst: any, dport: [5432, 3306]
376	    action: block, log: true, test: T-07
377	
378	  - id: POL-004
379	    desc: "Cấm egress từ DMZ-APP và TRUSTED ra WAN"
380	    zone: [dmz_app, trusted] -> wan
381	    proto: any, action: block, log: true, test: T-13
382	
383	  - id: POL-005
384	    desc: "SSH chỉ từ MGMT"
385	    zone: any -> any, proto: tcp, dport: 22
386	    src: MGMT_ONLY, action: pass, log: true
387	    else: { action: reject, test: T-11 }
388	    options: { max-src-conn: 10, max-src-conn-rate: "20/5", overload: { table: "ban_table", clear: 3600 } }
389	</pre>
390	
391	<h3>7.2 Renderer + apply không gián đoạn (Ansible)</h3>
392	<pre>
393	# roles/opnsense_policy/tasks/main.yml  (ý đồ, không phải code chạy ngay)
394	- name: Đồng bộ alias
395	  uri:
396	    url: "https://{{ opns_host }}/api/firewall/alias/{{ item.action }}{{ item.uuid or '' }}"
397	    method: POST
398	    user: "{{ api_key }}"; password: "{{ api_secret }}"
399	    body_format: json
400	    body: { alias: { name: "{{ item.name }}", type: "{{ item.type }}", content: "{{ item.items | join(' ') }}", descr: "{{ item.id }}" } }
401	  loop: "{{ alias_diff }}"
402	
403	- name: Đồng bộ rule (thêm/sửa theo POLICY-ID)
404	  uri:
405	    url: "https://{{ opns_host }}/api/firewall/rule_filter/{{ item.action }}{{ item.uuid or '' }}"
406	    ...
407	- name: Apply — reload filter, KHÔNG cắt state đang có
408	  uri: { url: "https://{{ opns_host }}/api/firewall/rule_filter/apply", method: post, ... }
409	- name: Kích hoạt thay đổi
410	  uri: { url: "https://{{ opns_host }}/api/firewall/filter/apply",   method: post, ... }
411	- name: Cờ an toàn cho NFR-02
412	  debug: { msg: "session trước/sau: {{ st_before }} -> {{ st_after }}" }
413	</pre>
414	<div class="note">
415	<strong>Trước khi viết renderer, làm việc này trong 30 phút:</strong> bật API trên OPNsense (System → Access → Users,
416	tạo user quyền <code>Admin: API</code>), rồi thử <code>GET /api/firewall/alias/searchAlias</code> bằng <code>curl</code> với
417	key/secret. Tên endpoint khác nhau theo phiên bản — xác nhận bằng <code>/api</code> docs trên chính thiết bị của bạn
418	rồi mới viết playbook. Đây là chỗ dễ mất 4 giờ vô ích nhất của cả dự án.
419	</div>
420	
421	<h3>7.3 CARP + pfsync + cfgsync (trên thiết bị)</h3>
422	<pre>
423	# Interface → Assignments: 5 OPT/WAN NIC, đặt descr = tên zone trong YAML
424	# System → Advanced → Networking:
425	#   Disable CARP preempt = ON (tránh flap khi master hồi)
426	#   Allow CARP shared advertisements = ON (2 con cùng host, cùng vmnet)
427	# Virtual IPs: CARP, vhid 1..5 theo zone, advskew 0 (master) / 100 (backup)
428	# System → High Availability:
429	#   Sync items: States, Rules, NAT, Aliases, Static routes
430	#   pfsync interface = vmnet_sync (KHÔNG dùng WAN)
431	#   Remote: 10.0.0.2  |  Sync user: quyền tối thiểu, key chung
432	# Trạng thái phải thấy: "This host is MASTER for vip 1/xxx" và pfsync có packet
433	sysctl net.inet.carp.preempt ; ifconfig carp ; tcpdump -i vmnet_sync -nn proto 24
434	</pre>
435	
436	<h3>7.4 Suricata inline + test fail-closed</h3>
437	<pre>
438	# Services → Intrusion Detection → Administration: Mode = IPS (NFQUEUE), interface = WAN, OPT1, OPT2
439	# Rules: enabled = emerging-ci, policy, trojan; test-local.rules viết tay cho hành vi lab
440	# Test fail-closed:
441	systemctl stop suricata            # hoặc tắt service trong plugin
442	nc -vz 10.0.0.100 443              # kỳ vọng: KHÔNG thông (fail-closed) hoặc thông + alert (fail-open)
443	                                   # → ghi lại lựa chọn và lý do vào báo cáo
444	</pre>
445	
446	<h3>7.5 HAProxy + Keepalived (đã giản lược)</h3>
447	<pre>
448	frontend in_https
449	    bind :443 ssl crt /local/domain/opnsense/haproxy/certs/lab.pem alpn h2,http/1.1
450	    http-request set-header X-Request-ID %[req.uuid]
451	    default_backend be_app
452	backend be_app
453	    option httpchk GET /healthz
454	    http-check expect status 200
455	    default-server inter 2s fastinter 1s fall 3 rise 2
456	    server web1 192.168.21.21:8443 check ssl verify required ca-file /certs/ca.crt client-cert /certs/lb-cli.pem
457	    server web2 192.168.21.22:8443 check ssl verify required ca-file /certs/ca.crt client-cert /certs/lb-cli.pem
458	</pre>
459	<pre>
460	vrrp_instance VI_LB {
461	    state MASTER            # node kia BACKUP + advskew 100
462	    interface eth1
463	    virtual_router_id 51
464	    priority 150
465	    advert_int 1            # multicast: VMware xử lý được, không cần unicast_peer
466	    virtual_ipaddress { 192.168.20.100/24 }
467	    track_script { chk_haproxy }
468	}
469	</pre>
470	
471	<h3>7.6 DB promote + fencing + PITR</h3>
472	<pre>
473	# /usr/local/bin/promote.sh — chạy khi primary chết (cron/watchdog đơn giản, không repmgrd)
474	repmgr standby promote -f /etc/repmgr/16/repmgr.conf
475	ip addr add 192.168.30.100/24 dev eth0 && arping -c3 -A -I eth0 192.168.30.100
476	ansible-playbook -i inv pb/refresh_alias.yml -e "db_vip_node=pg2"   # cập nhật alias firewall nếu cần
477	# fence node cũ:
478	ssh pg1 "systemctl stop postgresql@16-main; repmgr node set --name=pg1 --status=stopped"
479	# PITR:
480	pgbackrest --stanza=pglab --delta --type=time --target="2026-11-18 09:40:00+07" restore
481	</pre>
482	
483	<h2>8. Ma trận kiểm thử — 14 kịch bản</h2>
484	<table>
485	    <tr><th>Mã</th><th>Kịch bản</th><th>Thực hiện từ</th><th>PASS</th></tr>
486	    <tr><td>T-01</td><td>Phân phối tải qua VIP</td><td>attacker</td><td>30 req/s, cả 2 web ≥ 40% request</td></tr>
487	    <tr><td>T-02</td><td>Chết 1 web node</td><td>máy Hùng</td><td>Phát hiện ≤ 6 s, 0 lỗi 5xx, phiên (DB) còn</td></tr>
488	    <tr><td>T-03</td><td>Keepalived VIP đổi chủ</td><td>máy Hùng</td><td>≤ 10 s, mất ≤ 0.5% request đang truyền</td></tr>
489	    <tr><td>T-04</td><td><strong>CARP failover giữ session</strong></td><td>attacker</td><td>iperf3 + ssh đang chạy <em>không đứt</em>, đổi master ≤ 5 s</td></tr>
490	    <tr><td>T-05</td><td>Cắt đường pfsync/heartbeat</td><td>máy Hùng</td><td>Không có 2 MASTER; hành vi được giải thích + có alert</td></tr>
491	    <tr><td>T-06</td><td>cfgsync drift</td><td>cả hai</td><td>Sửa tay trên backup → master không bị ghi đè im lặng; <code>make drift</code> báo đúng</td></tr>
492	    <tr><td>T-07</td><td><strong>Ma trận chính sách 24 combo</strong></td><td>attacker/sensor/web/db</td><td>Khớp YAML 100%; mỗi rule có counter &gt; 0; WAN→DB và SSH phải bị chặn</td></tr>
493	    <tr><td>T-08</td><td><strong>Áp dụng policy dưới tải</strong></td><td>attacker</td><td>Thêm rule + reload: 0 gián đoạn, 0 lỗi 5xx, state giữ nguyên</td></tr>
494	    <tr><td>T-09</td><td>IPS chặn scan + payload</td><td>attacker</td><td>nmap bị phát hiện; ≥ 90% payload bị chặn ở IPS hoặc WAF</td></tr>
495	    <tr><td>T-10</td><td><strong>IPS fail-closed</strong></td><td>attacker</td><td>Suricata chết → hệ thống xử lý đúng lựa chọn đã công bố, có alert</td></tr>
496	    <tr><td>T-11</td><td>SSH brute force</td><td>attacker</td><td>Fail2Ban/overload table ban trong ≤ 5', unban đúng hạn, có log</td></tr>
497	    <tr><td>T-12</td><td>WAF false positive</td><td>attacker</td><td>15 request hợp lệ có nháy/JSON/unicode → 0 block sai</td></tr>
498	    <tr><td>T-13</td><td>DB failover + RPO + PITR</td><td>máy Hùng</td><td>Leader mới ≤ 40 s, commit cuối còn, restore tới timestamp verify 3 bản ghi</td></tr>
499	    <tr><td>T-14</td><td>Cấm egress / chống flood</td><td>web, attacker</td><td>Reverse shell từ web ra WAN thất bại; SYN flood 50k pkt/s không sập VIP</td></tr>
500	</table>
501	
502	<h2>9. PHÂN CÔNG CHI TIẾT THEO 7 GIAI ĐOẠN — 115.5 giờ</h2>
503	<p>
504	Mỗi giai đoạn có <strong>mốc ghép</strong> (hai người cùng xác nhận) và <strong>điều kiện ra</strong>.
505	Mã việc: <code>H##</code> = Hùng, <code>B##</code> = Bảo. Thứ tự đã sắp xếp để không ai phải chờ ai quá một ngày.
506	</p>
507	
508	<h3>GĐ0 — Hạ tầng + Tailscale control plane (ngày 1–2) · 8.5h</h3>
509	<table>
510	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
511	    <tr><td>H01</td><td><strong>Hùng</strong></td>
512	        <td>VMware Workstation Pro. Tạo 12 VM (opns1/2, lb1/2, web1/2, pg1/2, obs, ca, attacker, sensor) từ linked clone
513	        template Debian 12 + OPNsense. Dựng 6 vmnet theo mục 2.1 — <strong>tất cả private, không cấu hình bridged nào</strong>.
514	        Thêm <code>vmnet-sync</code> host-only giữa 2 con opns. Snapshot <code>clean</code>, chrony một source.</td>
515	        <td>3.5</td><td>Mỗi VM đúng số NIC theo mục 3; <code>vmrun list</code> thấy 12; <code>date</code> khớp nhau</td></tr>
516	    <tr><td>B01</td><td><strong>Bảo</strong></td>
517	        <td>Cài Tailscale cả hai máy, cùng tailnet, <code>tailscale set --expiry=0</code> (mục 2.4 #1).
518	        Trên máy Hùng: cài + bật <code>sshd</code> (StartupType Automatic, key-only).
519	        Kiểm từ máy Bảo: <code>ssh hung@100.64.x</code>, rồi <code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào 1 VM bất kỳ.
520	        Ghi IP tailscale của nhau vào <code>docs/interfaces.md</code>.</td>
521	        <td>1.5</td><td>ProxyJump vào được VM — <strong>đây là điều kiện sống còn của cả phương án</strong></td></tr>
522	    <tr><td>B02</td><td><strong>Bảo</strong></td>
523	        <td>Cấu hình <code>attacker</code> (nmap, hping3, hydra, curl, hey, bộ payload) và <code>sensor</code>
524	        (tcpdump, Zeek, rsyslog forward, promiscuous mode trên NIC vmnet-wan) — hai VM này nằm trên máy Hùng nhưng
525	        do Bảo sở hữu và vận hành.</td>
526	        <td>2</td><td>attacker ping 10.0.0.1; sensor bắt được traffic giữa attacker và CARP VIP</td></tr>
527	    <tr><td>B03</td><td><strong>Bảo</strong></td>
528	        <td>Repo Git + <code>.gitignore</code> (<code>*.key</code>, <code>certs/issued/</code>, <code>secrets.yml</code>) + gitleaks.
529	        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
530	        key SSH distribution cho 12 VM, inventory 6 nhóm vùng.</td>
531	        <td>1.5</td><td><code>ansible all -m ping</code> xanh đủ 12 VM; <code>make check</code> chạy được</td></tr>
532	    <tr><td colspan="5"><strong>Mốc ghép:</strong> hai người cùng chạy <code>scripts/verify_access.sh</code> — 3 phép kiểm:
533	        ProxyJump vào VM trong từng vùng (wan/dmzfront/dmzapp/trusted/mgmt), <code>vmrun start</code> từ xa, và
534	        <code>tailscale status</code> hiện <code>direct</code>. <strong>Bước ProxyJump trượt thì dừng ngay</strong> và bàn lại:
535	        hoặc chuyển sang mô hình ngồi chung một máy (giữ nguyên 14 kịch bản), hoặc quay lại phương án cáp. Không mò quá 60 phút.</td></tr>
536	</table>
537	
538	<h3>GĐ1 — Perimeter cơ bản &amp; mô hình chính sách (ngày 2–4) · 12h</h3>
539	<table>
540	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
541	    <tr><td>H02</td><td><strong>Hùng</strong></td>
542	        <td>OPNsense 5 vNIC, đặt <code>descr</code> đúng tên zone trong YAML. Alias/zone tạo tay để kiểm mô hình.
543	        DNAT 443 WAN → LB VIP. Routing 2 chiều + default gateway. GUI HTTPS với cert tạm. Chưa có LB thì test bằng
544	        <code>nc -lvnp 443</code> trên lb1.</td>
545	        <td>6</td><td><code>curl -k https://10.0.0.100</code> từ attacker chạm tới dịch vụ giả</td></tr>
546	    <tr><td>B04</td><td><strong>Bảo</strong></td>
547	        <td>Viết <code>policy/zones.yml</code> + <code>aliases</code> + <code>rules[]</code>: mỗi rule có <code>id: POL-xxx</code>,
548	        <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>. Thêm alias <code>ADMIN_SRC</code> (10.0.0.6)
549	        cho đường bastion. Kèm schema validation + <code>yamllint</code>. Lập bảng 24 combo (zone, đích, port) làm nguồn chân lý cho T-07.</td>
550	        <td>5</td><td>YAML được cả hai duyệt; <code>make policy-lint</code> xanh</td></tr>
551	    <tr><td>B05</td><td><strong>Bảo</strong></td>
552	        <td>Route MGMT xuyên 2 máy + rule permit MGMT → các vùng cho scrape/SSH/syslog (POL-006, POL-007). Bảo thêm vào YAML, Hùng áp dụng.</td>
553	        <td>1</td><td><code>obs</code> thu thập được từ MGMT sang DMZ-FRONT</td></tr>
554	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Hùng <em>xoá toàn bộ</em> alias/rule tạo tay và thay bằng đúng mô hình YAML của Bảo.
555	        Đây là lần đầu "chính sách là mã nguồn" được chứng minh — làm ở ngày 4, không dồn sang GĐ2.</td></tr>
556	</table>
557	
558	<h3>GĐ2 — CARP + renderer API + HAProxy (ngày 4–6) · 20h</h3>
559	<table>
560	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
561	    <tr><td>H03</td><td><strong>Hùng</strong></td>
562	        <td>CARP 5 vhid (WAN, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT), advskew 0/100, tắt <code>preempt</code>.
563	        <strong>pfsync chạy trên vmnet-sync</strong>, không để qua WAN. cfgsync với user quyền tối thiểu.
564	        Test T-04 (iperf3 + ssh đang chạy phải sống sót), T-05 (cắt vmnet-sync → không có 2 MASTER),
565	        T-06 (sửa tay trên backup → master không bị ghi đè im lặng).</td>
566	        <td>8</td><td>T-04, T-05, T-06 pass kèm số liệu</td></tr>
567	    <tr><td>B06</td><td><strong>Bảo</strong></td>
568	        <td><em>Bước 0 (30 phút, bắt buộc):</em> bật API trên OPNsense, <code>curl</code> 3 endpoint
569	        (<code>searchAlias</code>, <code>rule_filter/addRule</code>, <code>filter/apply</code>) để xác nhận tên theo đúng phiên bản.
570	        Rồi viết renderer YAML → API, idempotent (chạy 2 lần ra cùng rule set; xoá khỏi YAML thì rule biến mất trên thiết bị).
571	        Apply + reload, đo số state trước/sau để chứng minh NFR-02.</td>
572	        <td>6</td><td>T-08 pass: thêm rule lúc 30 req/s, 0 gián đoạn, state không giảm</td></tr>
573	    <tr><td>H04</td><td><strong>Hùng</strong></td>
574	        <td>HAProxy ×2: TLS termination (ALPN h2), mTLS xuống backend, <code>option httpchk GET /healthz</code> +
575	        <code>expect status 200</code>, stats bind MGMT. Đóng role Ansible.
576	        <em>(Chuyển từ Bảo sang Hùng để cân giờ — HAProxy chạy trên VM của Hùng.)</em></td>
577	        <td>6</td><td>Handshake qua VIP OK; backend không có client cert hợp lệ thì bị từ chối</td></tr>
578	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy renderer lên thiết bị của Hùng (lần đầu có mặt Hùng).
579	        Rủi ro lớn nhất của cả dự án nằm ở đây: nếu API không như mong đợi thì kích hoạt phương án B (render <code>config.xml</code> + reboot) —
580	        độ khó policy tụt 4.7 xuống 4.2 nhưng lịch trình sống.</td></tr>
581	</table>
582	
583	<h3>GĐ3 — IPS inline + dịch vụ + DB nền (ngày 6–8) · 22h</h3>
584	<table>
585	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
586	    <tr><td>H05</td><td><strong>Hùng</strong></td>
587	        <td>Suricata <strong>inline NFQUEUE</strong> trên WAN + DMZ-FRONT + DMZ-APP; ruleset (emerging + tự viết cho hành vi lab);
588	        đo latency tăng thêm và số state bị ảnh hưởng.</td>
589	        <td>6</td><td>nmap từ attacker sinh alert và bị chặn theo rule đã bật</td></tr>
590	    <tr><td>H06</td><td><strong>Hùng</strong></td>
591	        <td>PostgreSQL ×2 streaming replication, <code>synchronous_commit=on</code>, <code>hostssl</code> + scram, replication slot.</td>
592	        <td>4</td><td><code>pg_stat_replication</code> thấy standby; ghi primary thì đọc được ở standby</td></tr>
593	    <tr><td>B07</td><td><strong>Bảo</strong></td>
594	        <td>Policy validator: quét 24 combo từ attacker/sensor/web/db, so với YAML, đọc counter từng rule, xuất CSV. Thêm <code>make drift</code>.</td>
595	        <td>4</td><td>T-07 pass 24/24; mọi rule được kiểm đều có counter &gt; 0</td></tr>
596	    <tr><td>B08</td><td><strong>Bảo</strong></td>
597	        <td>Keepalived VIP multicast (vmnet của VMware xử lý được, không cần <code>unicast_peer</code>) +
598	        <code>track_script</code> gọi <code>haproxy -c</code>.</td>
599	        <td>3</td><td>T-03 pass: VIP đổi chủ ≤ 10 s</td></tr>
600	    <tr><td>B09</td><td><strong>Bảo</strong></td>
601	        <td>App 4 endpoint (<code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code>, <code>/session</code>),
602	        session lưu trong DB, Apache ×2 + hardening (SSH key-only, ẩn banner, CSP/HSTS), role Ansible.</td>
603	        <td>5</td><td>T-01, T-02 pass; phiên còn sau khi chết 1 web node</td></tr>
604	    <tr><td colspan="5"><strong>Checkpoint 1 (hết ngày 8):</strong> T-01, T-02, T-03, T-04, T-07 pass.
605	        Nếu T-04 hoặc T-07 chưa đạt thì cắt phạm vi <em>ngay bây giờ</em>, không phải ngày 12.</td></tr>
606	</table>
607	
608	<h3>GĐ4 — An ninh sâu + khôi phục (ngày 8–10) · 20.5h</h3>
609	<table>
610	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
611	    <tr><td>H07</td><td><strong>Hùng</strong></td>
612	        <td><code>promote.sh</code>: repmgr promote → gán DB VIP + <code>arping -A</code> → refresh alias firewall →
613	        <strong>fence</strong> node cũ (stop postgres + rule chặn 5432 từ IP của nó). Test <code>kill -9</code>, đo RTO và RPO.</td>
614	        <td>5</td><td>T-13a: leader mới ≤ 40 s, commit cuối còn, node cũ không ghi được</td></tr>
615	    <tr><td>H08</td><td><strong>Hùng</strong></td>
616	        <td><code>mod_security2</code> + OWASP CRS, <code>SecRuleEngine On</code>, ParanoiaLevel 2,
617	        file overrides trong Git mỗi rule có <code>Reason:</code>.</td>
618	        <td>4</td><td>T-12: 15 request hợp lệ → 0 block sai</td></tr>
619	    <tr><td>H09</td><td><strong>Hùng</strong></td>
620	        <td>Test <strong>fail-closed</strong>: dừng Suricata khi đang có kết nối → xác nhận hành vi (chặn hay mở),
621	        thêm alert "IPS xuống", viết đoạn công bố hành vi + lý do lựa chọn.</td>
622	        <td>2</td><td>T-10 pass + có đoạn văn thiết kế</td></tr>
623	    <tr><td>H10</td><td><strong>Hùng</strong></td>
624	        <td>Chống flood ở perimeter: <code>max-src-conn</code>, state table limit, syncookies; test SYN flood từ attacker.</td>
625	        <td>2</td><td>T-14a: 50k pkt/s không làm sập VIP, có số liệu state table</td></tr>
626	    <tr><td>H11</td><td><strong>Hùng</strong></td>
627	        <td>Hardening thiết bị biên: tắt service thừa, GUI TLS cert nội bộ, khoá root shell, anti-spoofing, bogon,
628	        private-network, NTP, backup <code>config.xml</code> có mã hoá.</td>
629	        <td>2</td><td>Checklist NFR-11 đạt, kèm ảnh trước/sau</td></tr>
630	    <tr><td>B10</td><td><strong>Bảo</strong></td>
631	        <td><strong>Tài liệu hoá out-of-band management path</strong> (mục 2.4 #7): viết rõ đường điều khiển đi qua
632	        hypervisor host chứ không qua perimeter, liệt kê hệ quả với NFR-13, và kiểm bastion vẫn còn nghĩa bằng test
633	        "attacker từ vmnet-wan thử SSH vào bastion phải bị từ chối"</td>
634	        <td>0.5</td><td>Có đoạn văn trong báo cáo + kết quả test SSH-from-WAN = block</td></tr>
635	    <tr><td>B11</td><td><strong>Bảo</strong></td>
636	        <td>step-ca: 2 authority (server + client), TTL 7 ngày, script gia hạn, cert cho lb/web phục vụ mTLS.</td>
637	        <td>3</td><td>mTLS dùng cert nội bộ, không còn cert tự sinh tạm</td></tr>
638	    <tr><td>B12</td><td><strong>Bảo</strong></td>
639	        <td>Remote syslog 3 nguồn (firewall, WAF, app) → Loki; index theo <code>POLICY-ID</code> và <code>X-Request-ID</code>.</td>
640	        <td>2</td><td>Truy vết được 1 request xuyên LB → web → DB bằng log</td></tr>
641	    <tr><td colspan="5"><strong>Checkpoint 2 (hết ngày 10):</strong> T-09, T-10, T-11, T-12, T-13 pass.
642	        Nếu T-13 chưa đạt, chạy bảng cắt khẩn cấp ở mục 11 <em>trong ngày 10</em>.</td></tr>
643	</table>
644	
645	<h3>GĐ5 — Kiểm chứng tấn công &amp; quan sát (ngày 10–12) · 16h</h3>
646	<table>
647	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
648	    <tr><td>B13</td><td><strong>Bảo</strong></td>
649	        <td>Prometheus + node/haproxy/postgres exporter, Grafana 3 dashboard (Dịch vụ / Perimeter+IPS / DB),
650	        Alertmanager 6 alert: mất MASTER CARP, IPS xuống, rule counter bất thường, 5xx&gt;1%, DB leader đổi, backup &gt;24h.</td>
651	        <td>4</td><td>Ít nhất 1 alert bắn thật trong điều kiện test</td></tr>
652	    <tr><td>B14</td><td><strong>Bảo</strong></td>
653	        <td>Attack harness 4 lớp từ <code>attacker</code>: (1) scan, (2) 30 payload web, (3) SSH brute force, (4) egress attempt từ web ra WAN.
654	        Mỗi lớp lấy bằng chứng từ <code>sensor</code> (tcpdump/Zeek) rồi đối chiếu log phòng thủ → bảng "gửi gì / ghi nhận gì / lệch ở đâu".
655	        Map MITRE: T1046, T1190, T1110, T1048, T1562.110.</td>
656	        <td>7</td><td>T-09, T-14 pass; bảng đối chiếu sensor-vs-defender hoàn chỉnh</td></tr>
657	    <tr><td>H12</td><td><strong>Hùng</strong></td>
658	        <td>pgBackRest: WAL archive + full + incremental lên repo (ssh/NFS sang obs). <strong>Diễn tập PITR</strong> tới timestamp
659	        chỉ định trên instance mới, verify 3 bản ghi mốc.</td>
660	        <td>5</td><td>T-13b pass + biên bản thời gian và dung lượng WAL</td></tr>
661	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy attack harness <em>trong khi</em> Hùng chạy PITR.
662	        Đây là lần duy nhất hai người thao tác đồng thời, và là phép thử thật cho việc lab có đứng dưới tải tấn công hay không.</td></tr>
663	</table>
664	
665	<h3>GĐ6 — Test, rebuild, báo cáo (ngày 12–14) · 16h</h3>
666	<table>
667	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
668	    <tr><td>H13</td><td><strong>Hùng</strong></td><td>Chạy lại 8 kịch bản phần biên: T-04, T-05, T-06, T-08, T-10, T-11, T-13, T-14a</td><td>3</td><td>8/8 pass, có CSV</td></tr>
669	    <tr><td>B15</td><td><strong>Bảo</strong></td><td>Chạy lại 6 kịch bản phần dịch vụ: T-01, T-02, T-03, T-07, T-09, T-12</td><td>3</td><td>6/6 pass</td></tr>
670	    <tr><td>B16</td><td><strong>Bảo</strong></td><td><code>run_matrix.sh</code> + schema CSV + <code>report.py</code> dựng bảng và biểu đồ</td><td>2</td><td>Một lệnh ra toàn bộ số liệu</td></tr>
671	    <tr><td>H14 / B17</td><td><strong>Mỗi người 1.5</strong></td><td>Rebuild drill ≤ 30 phút: xoá dịch vụ, dựng lại bằng Ansible, chạy lại test chính</td><td>3</td><td>Biên bản thời gian + kết quả test sau dựng</td></tr>
672	    <tr><td>B18</td><td><strong>Bảo</strong></td><td>Báo cáo: mô hình chính sách, policy-as-code, bằng chứng sensor-vs-log, bảng MITRE, trade-off đã cắt</td><td>3</td><td>Bản nháp hoàn chỉnh</td></tr>
673	    <tr><td>H15</td><td><strong>Hùng</strong></td><td>Báo cáo phần perimeter/CARP/IPS/PITR + video demo 6 kịch bản (T-04, T-08, T-09, T-10, T-13, T-14)</td><td>2</td><td>Video + snapshot <code>green</code> cuối</td></tr>
674	</table>
675	
676	<h3>Tổng kết phân công</h3>
677	<table>
678	    <tr><th>Giai đoạn</th><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Tổng</th><th>Điều kiện ra</th></tr>
679	    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
680	    <tr><td>GĐ1 Perimeter + mô hình</td><td>2–4</td><td>6</td><td>6</td><td>12</td><td>curl chạm dịch vụ giả; YAML được duyệt</td></tr>
681	    <tr><td>GĐ2 CARP + renderer + LB</td><td>4–6</td><td>14</td><td>6</td><td>20</td><td>T-04, T-05, T-06, T-08</td></tr>
682	    <tr><td>GĐ3 IPS + dịch vụ + DB nền</td><td>6–8</td><td>10</td><td>12</td><td>22</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-07</td></tr>
683	    <tr><td>GĐ4 An ninh sâu + khôi phục</td><td>8–10</td><td>15</td><td>5.5</td><td>20.5</td><td><strong>Checkpoint 2</strong>: T-09 tới T-13</td></tr>
684	    <tr><td>GĐ5 Kiểm chứng + quan sát</td><td>10–12</td><td>5</td><td>11</td><td>16</td><td>T-14 + PITR + alert thật</td></tr>
685	    <tr><td>GĐ6 Test + báo cáo</td><td>12–14</td><td>6.5</td><td>9.5</td><td>16</td><td>14/14 pass + video</td></tr>
686	    <tr><td><strong>Tổng</strong></td><td></td><td><strong>60</strong></td><td><strong>55.5</strong></td><td><strong>115.5</strong></td><td>82% quỹ, 24.5 giờ đệm</td></tr>
687	</table>
688	<div class="note">
689	<strong>Hai người cố tình không đối xứng.</strong> Hùng tập trung giờ ở GĐ2 + GĐ4 (29h) vì đó là CARP và an ninh sâu — phần cần hiểu thiết bị.
690	Bảo tập trung ở GĐ0 + GĐ3 + GĐ5 (28h) vì đó là control plane, validator và kiểm chứng tấn công — phần cần viết code và chạy script.
691	Chia đối xứng sẽ buộc một người phải làm việc của người kia ở trình độ thấp hơn.
692	</div>
693	
694	<h2>10. Lịch 14 ngày theo mã việc</h2>
695	<table>
696	    <tr><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Mốc chung cuối ngày</th></tr>
697	    <tr><td>1</td><td>H01 VMware + 12 VM + 6 vmnet riêng</td><td>B01 Tailscale 2 máy + tắt key expiry + OpenSSH Server trên Hùng</td><td><code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào được 1 VM bất kỳ</td></tr>
698	    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>
699	    <tr><td>3</td><td>H02 OPNsense 5 vùng + DNAT 443→LB VIP</td><td>B04 YAML policy + bảng 24 combo</td><td>attacker chạm được dịch vụ giả qua perimeter</td></tr>
700	    <tr><td>4</td><td>H02 routing + H03 CARP vhid</td><td>B04 tiếp, B05 route MGMT nội bộ + rule bastion</td><td><strong>Giao YAML cho Hùng, xoá toàn bộ rule tạo tay</strong></td></tr>
701	    <tr><td>5</td><td>H03 pfsync state sync</td><td>B06 <em>verify API 30 phút</em> rồi renderer</td><td>API xanh, hoặc quyết định phương án B (<code>config.xml</code>)</td></tr>
702	    <tr><td>6</td><td>H03 cfgsync, H04 HAProxy TLS/mTLS</td><td>B06 renderer + apply dưới tải</td><td>T-04 pass (session sống sót), T-08 pass</td></tr>
703	    <tr><td>7</td><td>H04 HAProxy + H06 PostgreSQL streaming</td><td>B09 app + web ×2</td><td>T-01, T-02 pass</td></tr>
704	    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
705	    <tr><td>9</td><td>H07 promote/fencing, H08 CRS, H09 fail-closed</td><td>B10 tài liệu hoá out-of-band mgmt path, B11 step-ca</td><td>T-09, T-10, T-12 pass</td></tr>
706	    <tr><td>10</td><td>H10 state limit, H11 hardening, H12 PITR (bắt đầu)</td><td>B12 syslog → Loki</td><td><strong>Checkpoint 2</strong>: T-13, T-14 pass</td></tr>
707	    <tr><td>11</td><td>H12 PITR drill + verify</td><td>B13 Prometheus/Grafana/6 alert, B14 attack harness + sensor</td><td>Chạy đủ 14 kịch bản lần đầu</td></tr>
708	    <tr><td>12</td><td>H13 chạy lại 8 kịch bản biên, H14 rebuild drill</td><td>B15 chạy lại 6 kịch bản dịch vụ, B16 <code>run_matrix.sh</code>, B17 rebuild drill</td><td>14/14 pass hoặc ghi chú fail trung thực</td></tr>
709	    <tr><td>13</td><td>H15 báo cáo perimeter + video demo</td><td>B18 báo cáo chính sách + MITRE + trade-off</td><td>Bản nháp hoàn chỉnh + video dự phòng</td></tr>
710	    <tr><td>14</td><td colspan="2">Dự phòng: chạy lại test cuối, luyện phản biện phần của đối phương</td><td>Sẵn sàng nộp</td></tr>
711	</table>
712	<div class="note">
713	<strong>Hai ngày then chốt.</strong> Ngày 1 chỉ có một việc thật: xác nhận ProxyJump vào được VM — mất 20 phút, và nếu không xong thì
714	dừng lại bàn phương án khác trước khi đầu tư thêm. Ngày 5 là bước <em>verify API OPNsense</em>: trượt ở đây bạn còn 3 ngày
715	để đổi sang render <code>config.xml</code> + reboot; thử ở ngày 8 thì không còn đường lùi.
716	</div>
717	
718	<h2>11. Bảng cắt khẩn cấp (kích hoạt ở Checkpoint 1 hoặc 2)</h2>
719	<table>
720	    <tr><th>Thứ tự</th><th>Cắt</th><th>Giờ giữ lại</th><th>Độ khó sau cắt</th></tr>
721	    <tr><td>1</td><td>H10 state limit + SYN flood</td><td>2</td><td>Perimeter 4.5 → 4.3</td></tr>
722	    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
723	    <tr><td>3</td><td>B14 phần đối chiếu sensor-vs-defender (chỉ dùng log phòng thủ)</td><td>3</td><td>Attack validation 4.2 → 3.9</td></tr>
724	    <tr><td>4</td><td>H09 test fail-closed (chuyển thành mô tả thiết kế + lý do)</td><td>2</td><td>IPS 4.6 → 4.3</td></tr>
725	    <tr><td>5</td><td>H08 CRS xuống DetectionOnly + còn 10 payload</td><td>2</td><td>WAF 4.2 → 3.6 ⚠</td></tr>
726	    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
727	    <tr><td colspan="2"><strong>TUYỆT ĐỐI KHÔNG CẮT</strong></td>
728	        <td colspan="2">H03 (CARP + pfsync), B06 (policy-as-code + apply không gián đoạn), H05 (IPS blocking),
729	        B07 (ma trận chính sách) — bốn thứ định danh bản v4. Cắt một trong bốn thì nên nộp bản v3.</td></tr>
730	</table>
731	
732	<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
733	<table>
734	    <tr><th>Rủi ro</th><th>Phòng ngừa</th></tr>
735	    <tr><td><strong>Tailscale hết hạn key sau 180 ngày</strong> → giữa kỳ học hai máy mất nhau, thông báo lại rất ít ngữ cảnh</td>
736	        <td>Chạy <code>tailscale set --expiry=0</code> trên cả hai máy <em>ngay ngày 1</em>, và ghi vào <code>docs/interfaces.md</code></td></tr>
737	    <tr><td>Cố bật <code>--advertise-routes</code> + IP forwarding trên Windows để "route vào VM"</td>
738	        <td><strong>Đừng.</strong> Chỉ dùng ProxyJump và <code>-L</code>: host đã có adapter trên từng vmnet nên nó tới được mọi VM mà không cần route. Đây là hố 2 giờ đã được ghi nhận</td></tr>
739	    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
740	    <tr><td>Mất Internet là mất quyền điều khiển lab</td>
741	        <td>Khi hai máy <em>cùng một mạng LAN</em>, Tailscale tự kết nối trực tiếp (không qua DERP) nên gần như không rủi ro.
742	        Khi ở khác mạng, luôn <code>tailscale status</code> xem là <code>direct</code> hay <code>DERP</code>; đang DERP mà chạy test timing thì ghi rõ vào biên bản</td></tr>
743	    <tr><td>Máy Hùng là điểm nghẽn: Hùng tắt máy thì Bảo không làm gì được ngoài viết code</td>
744	        <td>Quy ước giờ trực: Hùng bật lab trong khung Bảo cần (thông báo trước 1 ngày); phần việc của Bảo ngày đó chuyển sang B04/B18</td></tr>
745	    <tr><td>Đường quản trị không đi qua firewall → dễ bị hỏi "anh kiểm soát admin path thế nào"</td>
746	        <td>B10: viết rõ đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter,
747	        và bastion trong MGMT vẫn tồn tại để POL-005 còn ý nghĩa</td></tr>
748	    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
749	        <td>Ngày 5 <code>curl</code> thử 3 endpoint trước khi viết playbook; khoá <strong>cùng một phiên bản</strong> cho cả 2 con opns; luôn có phương án B</td></tr>
750	    <tr><td>cfgsync ghi đè cấu hình đang làm dở</td><td>Tắt auto-sync khi làm việc, chỉ sync khi chủ động; snapshot trước mỗi lần sync</td></tr>
751	    <tr><td>IPS inline làm sập kết nối ngay buổi demo</td><td>Nút tắt IPS trong 1 lệnh + snapshot <code>IPS-off</code>; test fail-closed ở ngày 9 chứ không phải ngày 14</td></tr>
752	    <tr><td>Hai người cùng sửa rule</td><td>Chỉ Bảo sửa <code>policy/*.yml</code>; Hùng chỉ chạy playbook; sửa trên GUI bị <code>make drift</code> bắt</td></tr>
753	    <tr><td>Lệch đồng hồ làm PITR và đối chiếu log sai</td><td>Một source NTP cho 12 VM + 2 host OS; kiểm <code>date</code> trước mỗi lần đo</td></tr>
754	</table>
755	
756	<h2>13. Sáu mươi phút đầu tiên — làm đủ rồi mới chia việc</h2>
757	<ol>
758	    <li>Cài VMware Workstation Pro trên máy Hùng (bản miễn phí cho cá nhân). Máy Bảo chỉ cần Tailscale + trình duyệt + WSL2.</li>
759	    <li>Cài Tailscale trên <strong>cả hai máy</strong>, đăng nhập cùng tailnet, chạy <code>tailscale set --expiry=0</code> mỗi máy.
760	        Ghi lại IP của nhau vào <code>docs/interfaces.md</code>.</li>
761	    <li>Trên máy Hùng: bật OpenSSH Server (<code>Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0</code>,
762	        <code>Start-Service sshd</code>, đặt StartupType Automatic). Kiểm từ máy Bảo: <code>ssh hung@&lt;tailscale-ip&gt; hostname</code>.</li>
763	    <li>Tạo <strong>1 VM Debian</strong> trên vmnet bất kỳ, rồi kiểm điều kiện quyết định của cả phương án này:
764	        <code>ssh -J hung@&lt;tailscale-ip&gt; ops@&lt;ip-VM&gt;</code>. Thông thì toàn bộ quyền điều khiển từ xa đã solved, không cần cáp.</li>
765	    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
766	        <strong>bước này quyết định 15 giờ làm việc của B06/B07</strong>.</li>
767	    <li>Tạo 2 VM OPNsense trên cùng <code>vmnet-sync</code>, cấu hình CARP 1 vhid, xác nhận <code>ifconfig carp</code> báo MASTER/BACKUP
768	        và <code>tcpdump -i vmnet-sync proto 24</code> thấy pfsync.</li>
769	    <li>Tạo 1 VM Debian thứ hai trên cùng segment, bật promiscuous, xác nhận <code>tcpdump</code> bắt được traffic của VM khác
770	        (đây là cơ chế hoạt động của <code>sensor</code>).</li>
771	    <li>Bước 4 trượt → dừng ngay, quay về mô hình "hai người ngồi chung một máy" (vẫn đủ 14 kịch bản, chỉ mất quyền làm việc từ xa).
772	        Bước 5 hoặc 6 trượt → dành tối đa 2 giờ, sau đó kích hoạt phương án B cho renderer hoặc ghi sensor vào <code>attacker</code>.</li>
773	</ol>
774	
775	</body>
776	</html>
777

#### Thinking

**Planning detailed HTML content inspection****Formulating parallel Grep searches**

#### Tool: Grep

**Input:**

```json
{
  "pattern": "package\\.json|pyproject\\.toml|requirements(?:\\.txt)?|Dockerfile|docker-compose|compose\\.ya?ml|\\.env(?:\\.example)?|Makefile|ansible\\.cfg|\\.gitignore|Cargo\\.toml|go\\.mod|pom\\.xml|build\\.gradle",
  "path": "D:\\Lab",
  "glob": "*",
  "output_mode": "content",
  "-B": 1,
  "-A": 1,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": true,
  "-o": false,
  "type": "",
  "head_limit": 300,
  "offset": 0,
  "multiline": false
}
```

**Response:**

ha-lb-security-lab.html:127:# ansible.cfg — một dòng cho toàn bộ playbook
--
ha-lb-security-lab.html:528:        <td>Repo Git + <code>.gitignore</code> (<code>*.key</code>, <code>certs/issued/</code>, <code>secrets.yml</code>) + gitleaks.
ha-lb-security-lab.html:529:        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
--
ha-lb-security-lab.html:698:    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>

#### Tool: Grep

**Input:**

```json
{
  "pattern": "WSL2|WSL|Docker|container|Podman|Kubernetes|GPU|CUDA|NVIDIA|ROCm|Suricata|OPNsense|VMware|VirtualBox|Tailscale",
  "path": "D:\\Lab",
  "glob": "*",
  "output_mode": "content",
  "-B": 1,
  "-A": 1,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": true,
  "-o": false,
  "type": "",
  "head_limit": 300,
  "offset": 0,
  "multiline": false
}
```

**Response:**

ha-lb-security-lab.html:5:<title>Đề tài Lab v4.2 — Firewall &amp; Security-First, 2 tuần, 1 máy host + Tailscale</title>
--
ha-lb-security-lab.html:31:dịch vụ được bảo vệ nhiều lớp — vận hành trên một máy host, điều khiển từ máy thứ hai qua Tailscale
--
ha-lb-security-lab.html:40:<strong>Tailscale</strong>; máy Bảo làm việc từ xa bằng <code>ProxyJump</code> + port-forward —
--
ha-lb-security-lab.html:47:<strong>Bảy điều bắt buộc lưu ý khi dùng Tailscale nằm ở mục 2.4.</strong> Hai điều dễ chết người nhất:
ha-lb-security-lab.html:48:mặc định Tailscale <em>hết hạn key sau 180 ngày</em>, và đừng cố <code>--advertise-routes</code> + IP forwarding trên Windows.
--
ha-lb-security-lab.html:57:    <tr><td>Thiết bị biên</td><td>1× Debian + nftables</td><td><strong>2× OPNsense, CARP + pfsync + cfgsync</strong>, 5 vùng</td>
--
ha-lb-security-lab.html:59:    <tr><td>IPS</td><td>Suricata pcap / alert</td><td><strong>Suricata inline NFQUEUE (blocking)</strong> + test fail-open</td>
--
ha-lb-security-lab.html:61:    <tr><td>Chính sách</td><td>File nftables trong Git</td><td><strong>YAML khai báo → render qua API OPNsense → apply không gián đoạn</strong></td>
--
ha-lb-security-lab.html:67:    <tr><td>Hypervisor</td><td>VirtualBox + unicast hack</td><td><strong>VMware Workstation Pro</strong> (miễn phí cá nhân)</td>
ha-lb-security-lab.html:68:        <td>CARP/pfsync dùng multicast — vmnet của VMware xử lý được, VirtualBox thì không ổn định</td></tr>
--
ha-lb-security-lab.html:77:<h2>2. Hạ tầng: một máy host + Tailscale control plane</h2>
--
ha-lb-security-lab.html:81:        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
--
ha-lb-security-lab.html:88:        <td>~2 GB cho WSL2 + Tailscale + trình duyệt</td></tr>
ha-lb-security-lab.html:89:    <tr><td>Phần mềm cần cài</td><td>VMware Workstation Pro, OpenSSH Server, Tailscale</td><td>Tailscale, WSL2 + Ansible, Git</td></tr>
--
ha-lb-security-lab.html:106:  Tailscale 100.64.x.x  ──ssh──►  host Windows của Hùng (100.64.x.x)
--
ha-lb-security-lab.html:120:ssh hung@100.64.x.x '"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list'
--
ha-lb-security-lab.html:134:ssh -L 8443:192.168.99.100:443  hung@100.64.x.x   # GUI OPNsense (CARP VIP vùng MGMT)
--
ha-lb-security-lab.html:146:Lý do phải dùng L2 thật: <strong>Tailscale không tạo broadcast domain chung giữa hai máy</strong> (mesh các <code>/32</code>),
--
ha-lb-security-lab.html:159:<h3>2.4 Bảy điều bắt buộc lưu ý khi dùng Tailscale</h3>
--
ha-lb-security-lab.html:163:        <td>Mặc định Tailscale hết hạn key sau 180 ngày. Hai máy chạy từ trước kỳ học → <em>giữa kỳ bị đá khỏi tailnet</em>,
ha-lb-security-lab.html:164:        và thông báo rất khó đoán. <code>tailscale set --expiry=0</code> trên cả hai máy, ghi vào <code>docs/interfaces.md</code>.</td></tr>
--
ha-lb-security-lab.html:168:    <tr><td>3</td><td><strong>OpenSSH Server, không phải Tailscale SSH, cho vai jump</strong></td>
ha-lb-security-lab.html:169:        <td>Tailscale SSH tiện để login nhưng hỗ trợ <code>-W</code>/ProxyJump không ổn định. Cài <code>sshd</code> Windows,
--
ha-lb-security-lab.html:173:        latency nhảy. Trước mỗi phép đo timing: <code>tailscale status | grep &lt;bạn&gt;</code>, và ghi <code>direct</code>/<code>DERP</code> vào biên bản test.</td></tr>
--
ha-lb-security-lab.html:187:    <tr><th></th><th>v4.1 — 2 cáp</th><th>v4.2 — Tailscale</th></tr>
--
ha-lb-security-lab.html:199:    <li>Máy Hùng: Power plan High performance, <em>never sleep</em> khi cắm điện; <code>sshd</code> automatic; Tailscale autostart.</li>
--
ha-lb-security-lab.html:204:    <li>Việc nào cần bật attacker/sensor thì bật, xong thì tắt — tiết kiệm 3.5 GB RAM và tránh Suricata chạy nền làm nhiễu phép đo.</li>
--
ha-lb-security-lab.html:210:  Tailscale 100.64.x ──ssh / ProxyJump──► host Windows + WSL2 Ansible + Git/CI
ha-lb-security-lab.html:211:  browser: Grafana, GUI OPNsense (qua ssh -L)
--
ha-lb-security-lab.html:251:    <tr><td>NFR-04</td><td>IPS fail-closed</td><td>Khi Suricata/NFQUEUE chết, traffic <strong>không</strong> được flow-through im lặng; phải có alert + test chứng minh hành vi đã chọn</td></tr>
--
ha-lb-security-lab.html:267:    <tr><td>OPNsense ×2 + CARP + pfsync + cfgsync</td><td><span class="b45">4.8</span></td><td>HA tầng 2 trên 5 vùng; pfsync giữ state; cfgsync phải không ghi đè tay; failover đo bằng session đang mở</td></tr>
--
ha-lb-security-lab.html:269:    <tr><td>Suricata inline IPS + fail-closed</td><td><span class="b45">4.6</span></td><td>NFQUEUE blocking thật, tuning rule, và trả lời câu hỏi "IPS chết thì hệ thống mở hay đóng"</td></tr>
--
ha-lb-security-lab.html:287:    <li>2× OPNsense, mỗi con 5 vNIC; VMXNET3; <code>sync</code> là vmnet host-only riêng cho pfsync + cfgsync (không để pfsync chạy trên WAN).</li>
--
ha-lb-security-lab.html:298:    <li>Renderer Ansible → gọi API OPNsense (alias add/set, rule_filter add/set, <code>apply</code> + <code>filter reload</code>) — reload không cắt state, đó là cơ sở của NFR-02. <em>Cần verify tên endpoint trên đúng phiên bản bạn cài; tài liệu API thay đổi theo release.</em></li>
--
ha-lb-security-lab.html:306:    <li>Suricata inline trên WAN + DMZ-FRONT + DMZ-APP (OPNsense plugin, chế độ NFQUEUE, blocking), ruleset: emerging-threats + rule tự viết cho hành vi của lab.</li>
ha-lb-security-lab.html:307:    <li>Test <strong>fail-closed</strong>: dừng dịch vụ Suricata khi đang có kết nối → xác nhận traffic bị chặn (không phải âm thầm flow-through) và có alert; ghi rõ lựa chọn thiết kế.</li>
--
ha-lb-security-lab.html:317:    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
--
ha-lb-security-lab.html:332:    <li>Remote syslog 3 nguồn từ OPNsense + web + db → obs (rsyslog → Loki); 3 dashboard Grafana với 4 panel chính: policy hit, IPS block, WAF block, state table.</li>
--
ha-lb-security-lab.html:336:    <li>Ansible + <code>make check</code> (lint + <code>haproxy -c</code> + <code>apachectl configtest</code> + <code>suricata -T</code> + gitleaks) + <code>make drift</code>.</li>
--
ha-lb-security-lab.html:393:# roles/opnsense_policy/tasks/main.yml  (ý đồ, không phải code chạy ngay)
--
ha-lb-security-lab.html:415:<strong>Trước khi viết renderer, làm việc này trong 30 phút:</strong> bật API trên OPNsense (System → Access → Users,
--
ha-lb-security-lab.html:436:<h3>7.4 Suricata inline + test fail-closed</h3>
--
ha-lb-security-lab.html:441:systemctl stop suricata            # hoặc tắt service trong plugin
--
ha-lb-security-lab.html:449:    bind :443 ssl crt /local/domain/opnsense/haproxy/certs/lab.pem alpn h2,http/1.1
--
ha-lb-security-lab.html:465:    advert_int 1            # multicast: VMware xử lý được, không cần unicast_peer
--
ha-lb-security-lab.html:495:    <tr><td>T-10</td><td><strong>IPS fail-closed</strong></td><td>attacker</td><td>Suricata chết → hệ thống xử lý đúng lựa chọn đã công bố, có alert</td></tr>
--
ha-lb-security-lab.html:508:<h3>GĐ0 — Hạ tầng + Tailscale control plane (ngày 1–2) · 8.5h</h3>
--
ha-lb-security-lab.html:512:        <td>VMware Workstation Pro. Tạo 12 VM (opns1/2, lb1/2, web1/2, pg1/2, obs, ca, attacker, sensor) từ linked clone
ha-lb-security-lab.html:513:        template Debian 12 + OPNsense. Dựng 6 vmnet theo mục 2.1 — <strong>tất cả private, không cấu hình bridged nào</strong>.
--
ha-lb-security-lab.html:517:        <td>Cài Tailscale cả hai máy, cùng tailnet, <code>tailscale set --expiry=0</code> (mục 2.4 #1).
--
ha-lb-security-lab.html:520:        Ghi IP tailscale của nhau vào <code>docs/interfaces.md</code>.</td>
--
ha-lb-security-lab.html:529:        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
--
ha-lb-security-lab.html:534:        <code>tailscale status</code> hiện <code>direct</code>. <strong>Bước ProxyJump trượt thì dừng ngay</strong> và bàn lại:
--
ha-lb-security-lab.html:542:        <td>OPNsense 5 vNIC, đặt <code>descr</code> đúng tên zone trong YAML. Alias/zone tạo tay để kiểm mô hình.
--
ha-lb-security-lab.html:568:        <td><em>Bước 0 (30 phút, bắt buộc):</em> bật API trên OPNsense, <code>curl</code> 3 endpoint
--
ha-lb-security-lab.html:587:        <td>Suricata <strong>inline NFQUEUE</strong> trên WAN + DMZ-FRONT + DMZ-APP; ruleset (emerging + tự viết cho hành vi lab);
--
ha-lb-security-lab.html:597:        <td>Keepalived VIP multicast (vmnet của VMware xử lý được, không cần <code>unicast_peer</code>) +
--
ha-lb-security-lab.html:620:        <td>Test <strong>fail-closed</strong>: dừng Suricata khi đang có kết nối → xác nhận hành vi (chặn hay mở),
--
ha-lb-security-lab.html:679:    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
--
ha-lb-security-lab.html:697:    <tr><td>1</td><td>H01 VMware + 12 VM + 6 vmnet riêng</td><td>B01 Tailscale 2 máy + tắt key expiry + OpenSSH Server trên Hùng</td><td><code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào được 1 VM bất kỳ</td></tr>
--
ha-lb-security-lab.html:699:    <tr><td>3</td><td>H02 OPNsense 5 vùng + DNAT 443→LB VIP</td><td>B04 YAML policy + bảng 24 combo</td><td>attacker chạm được dịch vụ giả qua perimeter</td></tr>
--
ha-lb-security-lab.html:704:    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
--
ha-lb-security-lab.html:714:dừng lại bàn phương án khác trước khi đầu tư thêm. Ngày 5 là bước <em>verify API OPNsense</em>: trượt ở đây bạn còn 3 ngày
--
ha-lb-security-lab.html:732:<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
--
ha-lb-security-lab.html:735:    <tr><td><strong>Tailscale hết hạn key sau 180 ngày</strong> → giữa kỳ học hai máy mất nhau, thông báo lại rất ít ngữ cảnh</td>
ha-lb-security-lab.html:736:        <td>Chạy <code>tailscale set --expiry=0</code> trên cả hai máy <em>ngay ngày 1</em>, và ghi vào <code>docs/interfaces.md</code></td></tr>
--
ha-lb-security-lab.html:739:    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
--
ha-lb-security-lab.html:741:        <td>Khi hai máy <em>cùng một mạng LAN</em>, Tailscale tự kết nối trực tiếp (không qua DERP) nên gần như không rủi ro.
ha-lb-security-lab.html:742:        Khi ở khác mạng, luôn <code>tailscale status</code> xem là <code>direct</code> hay <code>DERP</code>; đang DERP mà chạy test timing thì ghi rõ vào biên bản</td></tr>
--
ha-lb-security-lab.html:748:    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
--
ha-lb-security-lab.html:758:    <li>Cài VMware Workstation Pro trên máy Hùng (bản miễn phí cho cá nhân). Máy Bảo chỉ cần Tailscale + trình duyệt + WSL2.</li>
ha-lb-security-lab.html:759:    <li>Cài Tailscale trên <strong>cả hai máy</strong>, đăng nhập cùng tailnet, chạy <code>tailscale set --expiry=0</code> mỗi máy.
--
ha-lb-security-lab.html:762:        <code>Start-Service sshd</code>, đặt StartupType Automatic). Kiểm từ máy Bảo: <code>ssh hung@&lt;tailscale-ip&gt; hostname</code>.</li>
--
ha-lb-security-lab.html:764:        <code>ssh -J hung@&lt;tailscale-ip&gt; ops@&lt;ip-VM&gt;</code>. Thông thì toàn bộ quyền điều khiển từ xa đã solved, không cần cáp.</li>
ha-lb-security-lab.html:765:    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
--
ha-lb-security-lab.html:767:    <li>Tạo 2 VM OPNsense trên cùng <code>vmnet-sync</code>, cấu hình CARP 1 vhid, xác nhận <code>ifconfig carp</code> báo MASTER/BACKUP

#### Tool: Grep

**Input:**

```json
{
  "pattern": "volume|mount|NFS|repo|WAL|pgBackRest|PITR|backup|snapshot|config\\.xml|Loki|Prometheus|Grafana|syslog|tcpdump|Zeek",
  "path": "D:\\Lab",
  "glob": "*",
  "output_mode": "content",
  "-B": 1,
  "-A": 1,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": true,
  "-o": false,
  "type": "",
  "head_limit": 300,
  "offset": 0,
  "multiline": false
}
```

**Response:**

ha-lb-security-lab.html:5:<title>Đề tài Lab v4.2 — Firewall &amp; Security-First, 2 tuần, 1 máy host + Tailscale</title>
--
ha-lb-security-lab.html:28:<h1>ĐỀ TÀI LAB v4.2 — FIREWALL &amp; SECURITY-FIRST</h1>
--
ha-lb-security-lab.html:62:        <td>Điểm khó nhất và cũng là điểm ăn tiền nhất của phần firewall</td></tr>
ha-lb-security-lab.html:63:    <tr><td>Rate limit</td><td>Ở HAProxy (stick-table)</td><td><strong>Dịch chuyển xuống firewall</strong> (max states / alias + policy)</td>
--
ha-lb-security-lab.html:66:        <td>Firewall chỉ có ý nghĩa khi bị đánh từ ngoài; sensor cho bằng chứng độc lập</td></tr>
--
ha-lb-security-lab.html:70:        <td>Nhượng giờ cho firewall</td></tr>
ha-lb-security-lab.html:71:    <tr><td>DB</td><td>repmgr automatic failover</td><td>Streaming + <strong>promote có script + DB VIP</strong>, giữ PITR</td>
--
ha-lb-security-lab.html:81:        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
--
ha-lb-security-lab.html:132:ssh -L 3000:192.168.99.30:3000 hung@100.64.x.x    # Grafana   → http://localhost:3000
ha-lb-security-lab.html:133:ssh -L 9090:192.168.99.30:9090 hung@100.64.x.x    # Prometheus
--
ha-lb-security-lab.html:140:syslog receiver. Nhờ vậy ma trận chính sách không bị rỗng ở dòng SSH — nếu bỏ luôn bastion thì T-07 mất một nửa ý nghĩa.
--
ha-lb-security-lab.html:153:curl -k --resolve lab:443:192.168.20.100 https://lab/    # KHÔNG đi qua firewall
--
ha-lb-security-lab.html:180:    <tr><td>7</td><td><strong>Đường quản trị không qua firewall — phải nói rõ</strong></td>
--
ha-lb-security-lab.html:201:    <li>NTP: một source chung cho 12 VM + 2 host OS. PITR và đối chiếu log đa nguồn đều theo timestamp.</li>
ha-lb-security-lab.html:202:    <li>Snapshot: <code>clean</code> (ngày 1), <code>green</code> (cuối mỗi ngày), <code>before-&lt;T-xx&gt;</code> (trước mỗi test phá),
--
ha-lb-security-lab.html:211:  browser: Grafana, GUI OPNsense (qua ssh -L)
--
ha-lb-security-lab.html:222:   (Keepalived)               (repmgr + PITR)
--
ha-lb-security-lab.html:245:<h2>4. Ràng buộc phi chức năng (14 điều, firewall-first)</h2>
--
ha-lb-security-lab.html:255:    <tr><td>NFR-08</td><td>Log tập trung + tương quan</td><td>Firewall + IPS + WAF + app về obs, giữ ≥ 7 ngày; tái hiện được 1 chuỗi tấn công hoàn chỉnh bằng log</td></tr>
--
ha-lb-security-lab.html:257:    <tr><td>NFR-10</td><td>Khôi phục dữ liệu</td><td>PITR tới timestamp chỉ định, verify bản ghi; RPO = 0 khi mất DB primary</td></tr>
ha-lb-security-lab.html:258:    <tr><td>NFR-11</td><td>Hardening thiết bị biên</td><td>Tắt service thừa, GUI TLS + khoá root shell, NTP, backup config có mã hoá, bogon + private-network + anti-spoof bật</td></tr>
--
ha-lb-security-lab.html:272:    <tr><td>pgBackRest PITR</td><td><span class="b45">4.5</span></td><td>WAL archive + restore theo timestamp + verify dữ liệu</td></tr>
--
ha-lb-security-lab.html:280:    <tr><td colspan="2"><strong>TB toàn đề tài</strong></td><td><strong>≈ 4.35 / 5</strong> — cụm firewall–an ninh TB 4.6</td></tr>
--
ha-lb-security-lab.html:290:    <li><strong>cfgsync</strong>: tài khoản sync chỉ có quyền tối thiểu; test sửa tay trên backup → master không bị ghi đè im lặng, và ngược lại phải có cảnh báo drift.</li>
ha-lb-security-lab.html:291:    <li>Hardening: GUI HTTPS với cert nội bộ, tắt HTTP, vô hiệu service không dùng, <code>Allow OPT1..</code> tắt, anti-spoofing bật, bogon + private networks, NTP từ MGMT, định kỳ backup <code>config.xml</code> có mã hoá.</li>
--
ha-lb-security-lab.html:310:    <li><strong>Sensor</strong> (VM riêng trên vmnet-wan) chạy tcpdump + Zeek độc lập: với mỗi tấn công, đối chiếu "tôi đã gửi gì" và "hệ thống phòng thủ ghi nhận gì"; bảng lệch nhau là nội dung báo cáo có giá trị nhất.</li>
--
ha-lb-security-lab.html:317:    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
--
ha-lb-security-lab.html:325:    <li>Failover bằng script <code>promote.sh</code>: di chuyển <code>DB_VIP 192.168.30.100</code> sang standby + đẩy alias firewall cập nhật + <strong>fence</strong> node cũ (stop + rule chặn 5432 từ nó).</li>
--
ha-lb-security-lab.html:327:    <li>pgBackRest: full + incremental + WAL archive lên obs (repo NFS/ssh), <strong>diễn tập PITR</strong> tới timestamp và verify 3 bản ghi mốc.</li>
--
ha-lb-security-lab.html:332:    <li>Remote syslog 3 nguồn từ OPNsense + web + db → obs (rsyslog → Loki); 3 dashboard Grafana với 4 panel chính: policy hit, IPS block, WAF block, state table.</li>
--
ha-lb-security-lab.html:335:    <li>Prometheus: node_exporter, haproxy export, postgres_exporter; 6 alert: mất master CARP, IPS xuống, rule counter bất thường, 5xx &gt; 1%, DB leader đổi, PITR backup &gt; 24h chưa chạy.</li>
--
ha-lb-security-lab.html:396:    url: "https://{{ opns_host }}/api/firewall/alias/{{ item.action }}{{ item.uuid or '' }}"
--
ha-lb-security-lab.html:405:    url: "https://{{ opns_host }}/api/firewall/rule_filter/{{ item.action }}{{ item.uuid or '' }}"
--
ha-lb-security-lab.html:408:  uri: { url: "https://{{ opns_host }}/api/firewall/rule_filter/apply", method: post, ... }
--
ha-lb-security-lab.html:410:  uri: { url: "https://{{ opns_host }}/api/firewall/filter/apply",   method: post, ... }
--
ha-lb-security-lab.html:416:tạo user quyền <code>Admin: API</code>), rồi thử <code>GET /api/firewall/alias/searchAlias</code> bằng <code>curl</code> với
--
ha-lb-security-lab.html:427:# Virtual IPs: CARP, vhid 1..5 theo zone, advskew 0 (master) / 100 (backup)
--
ha-lb-security-lab.html:433:sysctl net.inet.carp.preempt ; ifconfig carp ; tcpdump -i vmnet_sync -nn proto 24
--
ha-lb-security-lab.html:461:    state MASTER            # node kia BACKUP + advskew 100
--
ha-lb-security-lab.html:471:<h3>7.6 DB promote + fencing + PITR</h3>
--
ha-lb-security-lab.html:476:ansible-playbook -i inv pb/refresh_alias.yml -e "db_vip_node=pg2"   # cập nhật alias firewall nếu cần
--
ha-lb-security-lab.html:479:# PITR:
ha-lb-security-lab.html:480:pgbackrest --stanza=pglab --delta --type=time --target="2026-11-18 09:40:00+07" restore
--
ha-lb-security-lab.html:491:    <tr><td>T-06</td><td>cfgsync drift</td><td>cả hai</td><td>Sửa tay trên backup → master không bị ghi đè im lặng; <code>make drift</code> báo đúng</td></tr>
--
ha-lb-security-lab.html:498:    <tr><td>T-13</td><td>DB failover + RPO + PITR</td><td>máy Hùng</td><td>Leader mới ≤ 40 s, commit cuối còn, restore tới timestamp verify 3 bản ghi</td></tr>
--
ha-lb-security-lab.html:514:        Thêm <code>vmnet-sync</code> host-only giữa 2 con opns. Snapshot <code>clean</code>, chrony một source.</td>
--
ha-lb-security-lab.html:524:        (tcpdump, Zeek, rsyslog forward, promiscuous mode trên NIC vmnet-wan) — hai VM này nằm trên máy Hùng nhưng
--
ha-lb-security-lab.html:528:        <td>Repo Git + <code>.gitignore</code> (<code>*.key</code>, <code>certs/issued/</code>, <code>secrets.yml</code>) + gitleaks.
--
ha-lb-security-lab.html:552:        <td>Route MGMT xuyên 2 máy + rule permit MGMT → các vùng cho scrape/SSH/syslog (POL-006, POL-007). Bảo thêm vào YAML, Hùng áp dụng.</td>
--
ha-lb-security-lab.html:565:        T-06 (sửa tay trên backup → master không bị ghi đè im lặng).</td>
--
ha-lb-security-lab.html:579:        Rủi ro lớn nhất của cả dự án nằm ở đây: nếu API không như mong đợi thì kích hoạt phương án B (render <code>config.xml</code> + reboot) —
--
ha-lb-security-lab.html:612:        <td><code>promote.sh</code>: repmgr promote → gán DB VIP + <code>arping -A</code> → refresh alias firewall →
--
ha-lb-security-lab.html:628:        private-network, NTP, backup <code>config.xml</code> có mã hoá.</td>
--
ha-lb-security-lab.html:639:        <td>Remote syslog 3 nguồn (firewall, WAF, app) → Loki; index theo <code>POLICY-ID</code> và <code>X-Request-ID</code>.</td>
--
ha-lb-security-lab.html:649:        <td>Prometheus + node/haproxy/postgres exporter, Grafana 3 dashboard (Dịch vụ / Perimeter+IPS / DB),
ha-lb-security-lab.html:650:        Alertmanager 6 alert: mất MASTER CARP, IPS xuống, rule counter bất thường, 5xx&gt;1%, DB leader đổi, backup &gt;24h.</td>
--
ha-lb-security-lab.html:654:        Mỗi lớp lấy bằng chứng từ <code>sensor</code> (tcpdump/Zeek) rồi đối chiếu log phòng thủ → bảng "gửi gì / ghi nhận gì / lệch ở đâu".
--
ha-lb-security-lab.html:658:        <td>pgBackRest: WAL archive + full + incremental lên repo (ssh/NFS sang obs). <strong>Diễn tập PITR</strong> tới timestamp
--
ha-lb-security-lab.html:660:        <td>5</td><td>T-13b pass + biên bản thời gian và dung lượng WAL</td></tr>
ha-lb-security-lab.html:661:    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy attack harness <em>trong khi</em> Hùng chạy PITR.
--
ha-lb-security-lab.html:670:    <tr><td>B16</td><td><strong>Bảo</strong></td><td><code>run_matrix.sh</code> + schema CSV + <code>report.py</code> dựng bảng và biểu đồ</td><td>2</td><td>Một lệnh ra toàn bộ số liệu</td></tr>
--
ha-lb-security-lab.html:673:    <tr><td>H15</td><td><strong>Hùng</strong></td><td>Báo cáo phần perimeter/CARP/IPS/PITR + video demo 6 kịch bản (T-04, T-08, T-09, T-10, T-13, T-14)</td><td>2</td><td>Video + snapshot <code>green</code> cuối</td></tr>
--
ha-lb-security-lab.html:684:    <tr><td>GĐ5 Kiểm chứng + quan sát</td><td>10–12</td><td>5</td><td>11</td><td>16</td><td>T-14 + PITR + alert thật</td></tr>
--
ha-lb-security-lab.html:698:    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>
--
ha-lb-security-lab.html:701:    <tr><td>5</td><td>H03 pfsync state sync</td><td>B06 <em>verify API 30 phút</em> rồi renderer</td><td>API xanh, hoặc quyết định phương án B (<code>config.xml</code>)</td></tr>
--
ha-lb-security-lab.html:706:    <tr><td>10</td><td>H10 state limit, H11 hardening, H12 PITR (bắt đầu)</td><td>B12 syslog → Loki</td><td><strong>Checkpoint 2</strong>: T-13, T-14 pass</td></tr>
ha-lb-security-lab.html:707:    <tr><td>11</td><td>H12 PITR drill + verify</td><td>B13 Prometheus/Grafana/6 alert, B14 attack harness + sensor</td><td>Chạy đủ 14 kịch bản lần đầu</td></tr>
--
ha-lb-security-lab.html:715:để đổi sang render <code>config.xml</code> + reboot; thử ở ngày 8 thì không còn đường lùi.
--
ha-lb-security-lab.html:726:    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
--
ha-lb-security-lab.html:745:    <tr><td>Đường quản trị không đi qua firewall → dễ bị hỏi "anh kiểm soát admin path thế nào"</td>
--
ha-lb-security-lab.html:750:    <tr><td>cfgsync ghi đè cấu hình đang làm dở</td><td>Tắt auto-sync khi làm việc, chỉ sync khi chủ động; snapshot trước mỗi lần sync</td></tr>
ha-lb-security-lab.html:751:    <tr><td>IPS inline làm sập kết nối ngay buổi demo</td><td>Nút tắt IPS trong 1 lệnh + snapshot <code>IPS-off</code>; test fail-closed ở ngày 9 chứ không phải ngày 14</td></tr>
--
ha-lb-security-lab.html:753:    <tr><td>Lệch đồng hồ làm PITR và đối chiếu log sai</td><td>Một source NTP cho 12 VM + 2 host OS; kiểm <code>date</code> trước mỗi lần đo</td></tr>
--
ha-lb-security-lab.html:765:    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
--
ha-lb-security-lab.html:767:    <li>Tạo 2 VM OPNsense trên cùng <code>vmnet-sync</code>, cấu hình CARP 1 vhid, xác nhận <code>ifconfig carp</code> báo MASTER/BACKUP
ha-lb-security-lab.html:768:        và <code>tcpdump -i vmnet-sync proto 24</code> thấy pfsync.</li>
ha-lb-security-lab.html:769:    <li>Tạo 1 VM Debian thứ hai trên cùng segment, bật promiscuous, xác nhận <code>tcpdump</code> bắt được traffic của VM khác

#### Tool: Grep

**Input:**

```json
{
  "pattern": "API|service|systemctl|apt|pip|npm|apt-get|PostgreSQL|HAProxy|Keepalived|Apache|mod_security|Ansible|Python|Node|Debian|OpenSSH|repmgr|step-ca",
  "path": "D:\\Lab",
  "glob": "*",
  "output_mode": "content",
  "-B": 0,
  "-A": 1,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": true,
  "-o": false,
  "type": "",
  "head_limit": 400,
  "offset": 0,
  "multiline": false
}
```

**Response:**

ha-lb-security-lab.html:39:<strong>Thay đổi so với v4.1:</strong> bỏ toàn bộ dây cáp và USB-Ethernet adapter. Hai laptop nối nhau qua
--
ha-lb-security-lab.html:57:    <tr><td>Thiết bị biên</td><td>1× Debian + nftables</td><td><strong>2× OPNsense, CARP + pfsync + cfgsync</strong>, 5 vùng</td>
--
ha-lb-security-lab.html:61:    <tr><td>Chính sách</td><td>File nftables trong Git</td><td><strong>YAML khai báo → render qua API OPNsense → apply không gián đoạn</strong></td>
--
ha-lb-security-lab.html:63:    <tr><td>Rate limit</td><td>Ở HAProxy (stick-table)</td><td><strong>Dịch chuyển xuống firewall</strong> (max states / alias + policy)</td>
--
ha-lb-security-lab.html:69:    <tr><td>HAProxy</td><td>8 tính năng, 15.5h</td><td>4 tính năng, 7h (TLS, mTLS, healthcheck, VIP)</td>
--
ha-lb-security-lab.html:71:    <tr><td>DB</td><td>repmgr automatic failover</td><td>Streaming + <strong>promote có script + DB VIP</strong>, giữ PITR</td>
--
ha-lb-security-lab.html:81:        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
--
ha-lb-security-lab.html:89:    <tr><td>Phần mềm cần cài</td><td>VMware Workstation Pro, OpenSSH Server, Tailscale</td><td>Tailscale, WSL2 + Ansible, Git</td></tr>
ha-lb-security-lab.html:90:    <tr><td>Chi phí thêm</td><td colspan="2"><strong>0 đồng</strong> — không cáp, không USB-Ethernet adapter, không switch</td></tr>
--
ha-lb-security-lab.html:100:  vmnet-dmzfront 192.168.20.0/24 : opns eth1, lb1 .10, lb2 .11, Keepalived VIP .100
--
ha-lb-security-lab.html:107:                                    │ host có adapter trên MỖI vmnet ở trên
--
ha-lb-security-lab.html:112:<em>từ host của Hùng</em> tới VM đích. Vì host OS vốn đã nằm trên từng vmnet (adapter VMnet1/VMnet8 tương ứng),
--
ha-lb-security-lab.html:127:# ansible.cfg — một dòng cho toàn bộ playbook
--
ha-lb-security-lab.html:135:ssh -L 8404:192.168.20.10:8404  hung@100.64.x.x   # HAProxy stats
--
ha-lb-security-lab.html:139:lab nữa, nhưng nó vẫn là node mà POL-005 ("SSH chỉ từ MGMT") áp dụng, và vẫn là nơi chạy <code>repmgr witness</code> +
--
ha-lb-security-lab.html:168:    <tr><td>3</td><td><strong>OpenSSH Server, không phải Tailscale SSH, cho vai jump</strong></td>
--
ha-lb-security-lab.html:188:    <tr><td>Chi phí phần cứng</td><td>2 USB-Ethernet adapter + 2 cáp (~500k)</td><td><strong>0đ</strong></td></tr>
--
ha-lb-security-lab.html:192:    <tr><td>NFR-13 giám sát ngoài vùng bảo vệ</td><td>Đúng nghĩa vật lý</td><td>Chỉ đúng nghĩa <em>logic</em> — obs ở vùng MGMT riêng, không node DMZ/TRUSTED nào ghi được</td></tr>
ha-lb-security-lab.html:193:    <tr><td>Lỗi ghép nối giữa 2 máy</td><td>Có (adapter, driver, bridged Wi-Fi, client isolation)</td><td><strong>Không còn</strong></td></tr>
--
ha-lb-security-lab.html:210:  Tailscale 100.64.x ──ssh / ProxyJump──► host Windows + WSL2 Ansible + Git/CI
--
ha-lb-security-lab.html:222:   (Keepalived)               (repmgr + PITR)
--
ha-lb-security-lab.html:226:    <tr><th>Vùng</th><th>Dải</th><th>Node</th><th>Nằm ở</th><th>Chính sách mặc định</th><th>IPS</th></tr>
--
ha-lb-security-lab.html:234:        <td>Chỉ nhận từ alias <code>APP_NODES</code>; cấm ra WAN</td><td>Không (giữ hiệu năng)</td></tr>
--
ha-lb-security-lab.html:240:qua 2 máy khi nó <em>không</em> chứa node nào mà attacker có thể lợi dụng để đi vòng qua perimeter. WAN là vùng
--
ha-lb-security-lab.html:249:    <tr><td>NFR-02</td><td>Áp dụng chính sách dưới tải</td><td>Thêm/sửa rule qua API: 0 gián đoạn, 0 lỗi 5xx, không cắt state đang có</td></tr>
--
ha-lb-security-lab.html:258:    <tr><td>NFR-11</td><td>Hardening thiết bị biên</td><td>Tắt service thừa, GUI TLS + khoá root shell, NTP, backup config có mã hoá, bogon + private-network + anti-spoof bật</td></tr>
--
ha-lb-security-lab.html:260:    <tr><td>NFR-13</td><td>Mặt phẳng giám sát ngoài vùng bảo vệ</td><td><code>obs</code>, <code>ca</code>, <code>sensor</code> chạy trên máy khác và không có node nào bị compromise xoá/sửa được bằng chứng về chính nó; kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert</td></tr>
ha-lb-security-lab.html:261:    <tr><td>NFR-14</td><td>Không có đường vòng L2</td><td>Không tồn tại segment nào vừa chứa attacker vừa chứa node dịch vụ được bảo vệ; chứng minh bằng <code>arping</code> thất bại từ attacker tới DMZ-FRONT</td></tr>
--
ha-lb-security-lab.html:268:    <tr><td>Policy-as-code (YAML → API → apply)</td><td><span class="b45">4.7</span></td><td>Thiết kế mô hình alias/zone + render + áp dụng không gián đoạn + validate 24 combo</td></tr>
--
ha-lb-security-lab.html:275:    <tr><td>DB failover + fencing + DB VIP</td><td><span class="b4">4.2</span></td><td>Promote có script, node cũ bị chặn không ghi được</td></tr>
ha-lb-security-lab.html:276:    <tr><td>HAProxy + Keepalived VIP</td><td><span class="b4">4.2</span></td><td>TLS, mTLS, health check, VIP multicast</td></tr>
--
ha-lb-security-lab.html:291:    <li>Hardening: GUI HTTPS với cert nội bộ, tắt HTTP, vô hiệu service không dùng, <code>Allow OPT1..</code> tắt, anti-spoofing bật, bogon + private networks, NTP từ MGMT, định kỳ backup <code>config.xml</code> có mã hoá.</li>
--
ha-lb-security-lab.html:297:    <li>Mô hình khai báo trong Git: <code>zones</code>, <code>aliases</code> (group objects: <code>APP_NODES</code>, <code>DB_VIP</code>, <code>MGMT_ALLOWED</code>), <code>services</code>, <code>rules[]</code> với <code>id: POL-xxx</code>, <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>.</li>
ha-lb-security-lab.html:298:    <li>Renderer Ansible → gọi API OPNsense (alias add/set, rule_filter add/set, <code>apply</code> + <code>filter reload</code>) — reload không cắt state, đó là cơ sở của NFR-02. <em>Cần verify tên endpoint trên đúng phiên bản bạn cài; tài liệu API thay đổi theo release.</em></li>
--
ha-lb-security-lab.html:308:    <li>CRS blocking trên Apache (mod_security2), ParanoiaLevel 2, file overrides trong Git kèm <code>Reason:</code>.</li>
--
ha-lb-security-lab.html:316:    <li>HAProxy ×2: TLS termination, mTLS xuống web, health check <code>/healthz</code>, stats bind MGMT.</li>
ha-lb-security-lab.html:317:    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
ha-lb-security-lab.html:318:    <li>App 4 endpoint: <code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code> (ghi DB), <code>/session</code>; session lưu trong PostgreSQL (chứng minh app stateless mà không cần Redis).</li>
--
ha-lb-security-lab.html:324:    <li>PostgreSQL 16 ×2, streaming replication, <code>synchronous_commit = on</code>, <code>hostssl</code> + scram.</li>
ha-lb-security-lab.html:325:    <li>Failover bằng script <code>promote.sh</code>: di chuyển <code>DB_VIP 192.168.30.100</code> sang standby + đẩy alias firewall cập nhật + <strong>fence</strong> node cũ (stop + rule chặn 5432 từ nó).</li>
--
ha-lb-security-lab.html:334:        nên không node nào trong vùng bị bảo vệ có khả năng xoá hoặc sửa bằng chứng về chính nó. Kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert.</li>
ha-lb-security-lab.html:335:    <li>Prometheus: node_exporter, haproxy export, postgres_exporter; 6 alert: mất master CARP, IPS xuống, rule counter bất thường, 5xx &gt; 1%, DB leader đổi, PITR backup &gt; 24h chưa chạy.</li>
ha-lb-security-lab.html:336:    <li>Ansible + <code>make check</code> (lint + <code>haproxy -c</code> + <code>apachectl configtest</code> + <code>suricata -T</code> + gitleaks) + <code>make drift</code>.</li>
--
ha-lb-security-lab.html:354:  APP_NODES: { type: network, items: [192.168.21.21/32, 192.168.21.22/32] }
--
ha-lb-security-lab.html:367:    desc: "Web truy cập DB, chỉ từ alias APP_NODES"
--
ha-lb-security-lab.html:369:    proto: tcp, src: APP_NODES, dst: DB_VIP, dport: 5432
--
ha-lb-security-lab.html:391:<h3>7.2 Renderer + apply không gián đoạn (Ansible)</h3>
--
ha-lb-security-lab.html:396:    url: "https://{{ opns_host }}/api/firewall/alias/{{ item.action }}{{ item.uuid or '' }}"
--
ha-lb-security-lab.html:398:    user: "{{ api_key }}"; password: "{{ api_secret }}"
--
ha-lb-security-lab.html:405:    url: "https://{{ opns_host }}/api/firewall/rule_filter/{{ item.action }}{{ item.uuid or '' }}"
--
ha-lb-security-lab.html:408:  uri: { url: "https://{{ opns_host }}/api/firewall/rule_filter/apply", method: post, ... }
--
ha-lb-security-lab.html:410:  uri: { url: "https://{{ opns_host }}/api/firewall/filter/apply",   method: post, ... }
--
ha-lb-security-lab.html:415:<strong>Trước khi viết renderer, làm việc này trong 30 phút:</strong> bật API trên OPNsense (System → Access → Users,
ha-lb-security-lab.html:416:tạo user quyền <code>Admin: API</code>), rồi thử <code>GET /api/firewall/alias/searchAlias</code> bằng <code>curl</code> với
ha-lb-security-lab.html:417:key/secret. Tên endpoint khác nhau theo phiên bản — xác nhận bằng <code>/api</code> docs trên chính thiết bị của bạn
--
ha-lb-security-lab.html:438:# Services → Intrusion Detection → Administration: Mode = IPS (NFQUEUE), interface = WAN, OPT1, OPT2
--
ha-lb-security-lab.html:441:systemctl stop suricata            # hoặc tắt service trong plugin
--
ha-lb-security-lab.html:446:<h3>7.5 HAProxy + Keepalived (đã giản lược)</h3>
--
ha-lb-security-lab.html:449:    bind :443 ssl crt /local/domain/opnsense/haproxy/certs/lab.pem alpn h2,http/1.1
--
ha-lb-security-lab.html:461:    state MASTER            # node kia BACKUP + advskew 100
--
ha-lb-security-lab.html:467:    track_script { chk_haproxy }
--
ha-lb-security-lab.html:473:# /usr/local/bin/promote.sh — chạy khi primary chết (cron/watchdog đơn giản, không repmgrd)
ha-lb-security-lab.html:474:repmgr standby promote -f /etc/repmgr/16/repmgr.conf
--
ha-lb-security-lab.html:476:ansible-playbook -i inv pb/refresh_alias.yml -e "db_vip_node=pg2"   # cập nhật alias firewall nếu cần
ha-lb-security-lab.html:477:# fence node cũ:
ha-lb-security-lab.html:478:ssh pg1 "systemctl stop postgresql@16-main; repmgr node set --name=pg1 --status=stopped"
--
ha-lb-security-lab.html:487:    <tr><td>T-02</td><td>Chết 1 web node</td><td>máy Hùng</td><td>Phát hiện ≤ 6 s, 0 lỗi 5xx, phiên (DB) còn</td></tr>
ha-lb-security-lab.html:488:    <tr><td>T-03</td><td>Keepalived VIP đổi chủ</td><td>máy Hùng</td><td>≤ 10 s, mất ≤ 0.5% request đang truyền</td></tr>
--
ha-lb-security-lab.html:513:        template Debian 12 + OPNsense. Dựng 6 vmnet theo mục 2.1 — <strong>tất cả private, không cấu hình bridged nào</strong>.
--
ha-lb-security-lab.html:529:        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
--
ha-lb-security-lab.html:531:        <td>1.5</td><td><code>ansible all -m ping</code> xanh đủ 12 VM; <code>make check</code> chạy được</td></tr>
--
ha-lb-security-lab.html:558:<h3>GĐ2 — CARP + renderer API + HAProxy (ngày 4–6) · 20h</h3>
--
ha-lb-security-lab.html:568:        <td><em>Bước 0 (30 phút, bắt buộc):</em> bật API trên OPNsense, <code>curl</code> 3 endpoint
--
ha-lb-security-lab.html:570:        Rồi viết renderer YAML → API, idempotent (chạy 2 lần ra cùng rule set; xoá khỏi YAML thì rule biến mất trên thiết bị).
--
ha-lb-security-lab.html:574:        <td>HAProxy ×2: TLS termination (ALPN h2), mTLS xuống backend, <code>option httpchk GET /healthz</code> +
ha-lb-security-lab.html:575:        <code>expect status 200</code>, stats bind MGMT. Đóng role Ansible.
ha-lb-security-lab.html:576:        <em>(Chuyển từ Bảo sang Hùng để cân giờ — HAProxy chạy trên VM của Hùng.)</em></td>
--
ha-lb-security-lab.html:579:        Rủi ro lớn nhất của cả dự án nằm ở đây: nếu API không như mong đợi thì kích hoạt phương án B (render <code>config.xml</code> + reboot) —
--
ha-lb-security-lab.html:591:        <td>PostgreSQL ×2 streaming replication, <code>synchronous_commit=on</code>, <code>hostssl</code> + scram, replication slot.</td>
--
ha-lb-security-lab.html:597:        <td>Keepalived VIP multicast (vmnet của VMware xử lý được, không cần <code>unicast_peer</code>) +
ha-lb-security-lab.html:598:        <code>track_script</code> gọi <code>haproxy -c</code>.</td>
--
ha-lb-security-lab.html:602:        session lưu trong DB, Apache ×2 + hardening (SSH key-only, ẩn banner, CSP/HSTS), role Ansible.</td>
ha-lb-security-lab.html:603:        <td>5</td><td>T-01, T-02 pass; phiên còn sau khi chết 1 web node</td></tr>
--
ha-lb-security-lab.html:612:        <td><code>promote.sh</code>: repmgr promote → gán DB VIP + <code>arping -A</code> → refresh alias firewall →
ha-lb-security-lab.html:613:        <strong>fence</strong> node cũ (stop postgres + rule chặn 5432 từ IP của nó). Test <code>kill -9</code>, đo RTO và RPO.</td>
ha-lb-security-lab.html:614:        <td>5</td><td>T-13a: leader mới ≤ 40 s, commit cuối còn, node cũ không ghi được</td></tr>
--
ha-lb-security-lab.html:616:        <td><code>mod_security2</code> + OWASP CRS, <code>SecRuleEngine On</code>, ParanoiaLevel 2,
--
ha-lb-security-lab.html:627:        <td>Hardening thiết bị biên: tắt service thừa, GUI TLS cert nội bộ, khoá root shell, anti-spoofing, bogon,
--
ha-lb-security-lab.html:636:        <td>step-ca: 2 authority (server + client), TTL 7 ngày, script gia hạn, cert cho lb/web phục vụ mTLS.</td>
--
ha-lb-security-lab.html:649:        <td>Prometheus + node/haproxy/postgres exporter, Grafana 3 dashboard (Dịch vụ / Perimeter+IPS / DB),
--
ha-lb-security-lab.html:671:    <tr><td>H14 / B17</td><td><strong>Mỗi người 1.5</strong></td><td>Rebuild drill ≤ 30 phút: xoá dịch vụ, dựng lại bằng Ansible, chạy lại test chính</td><td>3</td><td>Biên bản thời gian + kết quả test sau dựng</td></tr>
--
ha-lb-security-lab.html:679:    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
--
ha-lb-security-lab.html:697:    <tr><td>1</td><td>H01 VMware + 12 VM + 6 vmnet riêng</td><td>B01 Tailscale 2 máy + tắt key expiry + OpenSSH Server trên Hùng</td><td><code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào được 1 VM bất kỳ</td></tr>
ha-lb-security-lab.html:698:    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>
--
ha-lb-security-lab.html:701:    <tr><td>5</td><td>H03 pfsync state sync</td><td>B06 <em>verify API 30 phút</em> rồi renderer</td><td>API xanh, hoặc quyết định phương án B (<code>config.xml</code>)</td></tr>
ha-lb-security-lab.html:702:    <tr><td>6</td><td>H03 cfgsync, H04 HAProxy TLS/mTLS</td><td>B06 renderer + apply dưới tải</td><td>T-04 pass (session sống sót), T-08 pass</td></tr>
ha-lb-security-lab.html:703:    <tr><td>7</td><td>H04 HAProxy + H06 PostgreSQL streaming</td><td>B09 app + web ×2</td><td>T-01, T-02 pass</td></tr>
ha-lb-security-lab.html:704:    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
ha-lb-security-lab.html:705:    <tr><td>9</td><td>H07 promote/fencing, H08 CRS, H09 fail-closed</td><td>B10 tài liệu hoá out-of-band mgmt path, B11 step-ca</td><td>T-09, T-10, T-12 pass</td></tr>
--
ha-lb-security-lab.html:714:dừng lại bàn phương án khác trước khi đầu tư thêm. Ngày 5 là bước <em>verify API OPNsense</em>: trượt ở đây bạn còn 3 ngày
--
ha-lb-security-lab.html:722:    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
--
ha-lb-security-lab.html:738:        <td><strong>Đừng.</strong> Chỉ dùng ProxyJump và <code>-L</code>: host đã có adapter trên từng vmnet nên nó tới được mọi VM mà không cần route. Đây là hố 2 giờ đã được ghi nhận</td></tr>
ha-lb-security-lab.html:739:    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
--
ha-lb-security-lab.html:748:    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
--
ha-lb-security-lab.html:761:    <li>Trên máy Hùng: bật OpenSSH Server (<code>Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0</code>,
ha-lb-security-lab.html:762:        <code>Start-Service sshd</code>, đặt StartupType Automatic). Kiểm từ máy Bảo: <code>ssh hung@&lt;tailscale-ip&gt; hostname</code>.</li>
ha-lb-security-lab.html:763:    <li>Tạo <strong>1 VM Debian</strong> trên vmnet bất kỳ, rồi kiểm điều kiện quyết định của cả phương án này:
--
ha-lb-security-lab.html:765:    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
--
ha-lb-security-lab.html:769:    <li>Tạo 1 VM Debian thứ hai trên cùng segment, bật promiscuous, xác nhận <code>tcpdump</code> bắt được traffic của VM khác

#### Thinking

**Verifying project files with glob patterns****Planning multi-pattern glob search for manifests**

#### Tool: Glob

**Input:**

```json
{
  "pattern": "**/*",
  "path": "D:\\Lab"
}
```

**Response:**

ha-lb-security-lab.html

#### Tool: Glob

**Input:**

```json
{
  "pattern": "**/{package.json,pyproject.toml,requirements*.txt,Dockerfile,docker-compose*.yml,docker-compose*.yaml,compose*.yml,compose*.yaml,.env.example,Makefile,ansible.cfg,*.tf,*.yaml,*.yml}",
  "path": "D:\\Lab"
}
```

**Response:**

No files found

#### Tool: Glob

**Input:**

```json
{
  "pattern": "**/*.{sh,py,ps1,psm1,js,ts,json,toml,ini,cfg,conf,env}",
  "path": "D:\\Lab"
}
```

**Response:**

No files found

#### Thinking

**Synthesizing Vietnamese project report with file references****Detailing project structure and runtime environment**

#### Thinking

**Assessing WSL2 suitability and limitations****Listing key validation checkpoints and discrepancies**

Đã khảo sát chỉ đọc. Workspace `D:\Lab` hiện chỉ có một file HTML, chưa có source code hay cấu trúc dự án thực thi.

**Cấu trúc / dự án**
- Không có thư mục con; chỉ có `D:\Lab\ha-lb-security-lab.html:1`.
- Đây là tài liệu thiết kế lab v4.2, không phải repository đã triển khai.
- Kiến trúc mô tả 12 VM trên máy Hùng, 6 vmnet private, máy Bảo chỉ làm control plane từ xa: `D:\Lab\ha-lb-security-lab.html:77`.
- Các VM dự kiến: `opns1/2`, `lb1/2`, `web1/2`, `pg1/2`, `obs`, `ca`, `attacker`, `sensor`: `D:\Lab\ha-lb-security-lab.html:82`.

**Runtime / dependency**
- Không tìm thấy manifest hoặc cấu hình thực tế: `package.json`, `pyproject.toml`, `requirements*.txt`, `Dockerfile`, Compose, `.env.example`, `Makefile`, `ansible.cfg`, `go.mod`, `Cargo.toml` đều chưa tồn tại trong workspace.
- Runtime được mô tả trong tài liệu:
  - Host Windows + VMware Workstation Pro, OpenSSH Server, Tailscale.
  - WSL2 + Ansible + Git/CI trên máy Bảo: `D:\Lab\ha-lb-security-lab.html:79`, `D:\Lab\ha-lb-security-lab.html:89`.
  - Debian 12 làm template cho các VM Linux: `D:\Lab\ha-lb-security-lab.html:511`.
- Dependency/dịch vụ dự kiến gồm OPNsense, Suricata, HAProxy, Keepalived, Apache/mod_security2, PostgreSQL 16, repmgr, pgBackRest, rsyslog/Loki, Prometheus/Grafana, Zeek, tcpdump và step-ca: `D:\Lab\ha-lb-security-lab.html:304`, `D:\Lab\ha-lb-security-lab.html:314`, `D:\Lab\ha-lb-security-lab.html:322`, `D:\Lab\ha-lb-security-lab.html:330`.

**Dịch vụ / workload**
- Firewall perimeter: 2 OPNsense, CARP, pfsync, cfgsync, 5 vùng mạng: `D:\Lab\ha-lb-security-lab.html:57`, `D:\Lab\ha-lb-security-lab.html:207`.
- IPS inline Suricata qua NFQUEUE trên WAN/DMZ, WAF CRS trên Apache: `D:\Lab\ha-lb-security-lab.html:304`.
- Load balancer HAProxy ×2 với TLS, mTLS, health check và Keepalived VIP: `D:\Lab\ha-lb-security-lab.html:314`.
- Web/app ×2, session lưu PostgreSQL; PostgreSQL ×2 streaming replication, DB VIP, promote/fencing và PITR: `D:\Lab\ha-lb-security-lab.html:318`, `D:\Lab\ha-lb-security-lab.html:322`.
- Quan sát tập trung qua syslog/Loki, Prometheus/Grafana và exporter: `D:\Lab\ha-lb-security-lab.html:330`.
- Workload Linux/container/GPU:
  - Có dấu hiệu workload Linux/VM mạnh.
  - Không thấy Docker, Podman, Kubernetes, container image/runtime, CUDA, NVIDIA hoặc ROCm.
  - Không có cấu hình GPU passthrough.

**Dữ liệu / volume / lưu trữ**
- PostgreSQL có WAL archive, full/incremental backup và PITR qua pgBackRest.
- Repository backup dự kiến đặt trên `obs` qua SSH hoặc NFS: `D:\Lab\ha-lb-security-lab.html:324`.
- OPNsense cần backup `config.xml` có mã hóa; VMware dùng snapshot `clean`, `green`, `before-*`, `IPS-off`: `D:\Lab\ha-lb-security-lab.html:197`, `D:\Lab\ha-lb-security-lab.html:291`.
- Chưa có volume mapping, mount point, filesystem layout hoặc policy retention thực tế.
- Không có Docker volume/Compose volume nào để kiểm tra.

**Mức phù hợp với WSL2**
- Phù hợp cao cho vai trò control plane: Ansible, Git/CI, SSH ProxyJump, script kiểm thử và trình duyệt truy cập Grafana/Prometheus qua port-forward: `D:\Lab\ha-lb-security-lab.html:117`, `D:\Lab\ha-lb-security-lab.html:208`.
- Không nên xem WSL2 là nền tảng thay thế cho phần lab chính; thiết kế phụ thuộc VMware Workstation, nhiều vNIC/vmnet, multicast CARP/Keepalived, pfsync và promiscuous capture.
- Cần kiểm tra thực tế WSL2 → Windows OpenSSH → VMware host → từng VM; tài liệu chủ trương không dùng route advertisement hoặc IP forwarding: `D:\Lab\ha-lb-security-lab.html:159`.
- Tài nguyên dự kiến khoảng 17 GB RAM khi bật đủ VM, trên host 32 GB: `D:\Lab\ha-lb-security-lab.html:85`. Đây là mức sát, cần chừa RAM cho Windows, VMware và WSL2.

**File nhạy cảm**
- Không tìm thấy file `.env`, secrets, key, certificate hoặc credential thực tế.
- HTML có placeholder/tên biến như `api_key`, `api_secret` và thông tin topology, IP nội bộ, username SSH; không thấy giá trị bí mật thực tế: `D:\Lab\ha-lb-security-lab.html:393`.
- Không in lại các thông tin vận hành nhạy cảm ngoài mức cần thiết.

**Điểm cần kiểm tra thêm**
- Tạo repository thực tế và pin phiên bản cho Ansible, OPNsense API, Debian, PostgreSQL, Suricata, HAProxy và các exporter; hiện chỉ có tài liệu.
- Xác nhận endpoint API OPNsense đúng với phiên bản cài đặt trước khi viết renderer: `D:\Lab\ha-lb-security-lab.html:414`.
- Kiểm chứng VMware có hỗ trợ ổn định CARP/pfsync/VRRP multicast, vmnet isolation và sensor promiscuous capture.
- Quyết định rõ IPS fail-open hay fail-closed: tài liệu có chỗ ghi “test fail-open”, nhưng NFR và phần test yêu cầu fail-closed; `D:\Lab\ha-lb-security-lab.html:59`, `D:\Lab\ha-lb-security-lab.html:249`, `D:\Lab\ha-lb-security-lab.html:436`.
- Làm rõ mức đáp ứng NFR-13: tài liệu thừa nhận `obs`, `ca`, `attacker`, `sensor` cùng nằm trên máy Hùng trong v4.2, nên chỉ đạt phân tách logic chứ không phải độc lập vật lý: `D:\Lab\ha-lb-security-lab.html:43`, `D:\Lab\ha-lb-security-lab.html:190`.
- Bổ sung kế hoạch quản lý secret, certificate, backup encryption key và quyền truy cập; hiện mới có quy ước `.gitignore` dự kiến: `D:\Lab\ha-lb-security-lab.html:527`.

#### Thinking

**Inspecting .wslconfig and WSL status****Running PowerShell WSL commands and reading .wslconfig**

Khảo sát ban đầu cho thấy `D:\Lab` hiện là một tài liệu thiết kế lab VMware nhiều VM, chưa phải repository triển khai; WSL có vẻ phù hợp làm control plane hơn là thay thế toàn bộ lab. Mình đang xác nhận distro và đọc giới hạn tài nguyên thực tế trước khi kết luận.

#### Tool: Read

**Input:**

```json
{
  "file_path": "C:\\Users\\Administrator\\.wslconfig",
  "offset": 1,
  "limit": 100,
  "pages": ""
}
```

**Response:**

1	# Cấu hình WSL2 cho Laptop Acer Nitro AN515-58 (Tổng RAM 32GB, 16 luồng)
2	# Phân bổ: 14 GB cho WSL2 – ~18 GB cho Windows Host
3	# Lý do giảm (2026-11-02): commit Windows chỉ còn ~3 GB trống (vmmemWSL commit 11.3 GB),
4	# host bị ép bộ nhớ -> guest page-fault chờ I/O -> soft lockup 22-49s -> IDE mất heartbeat.
5	
6	[wsl2]
7	# 1. RAM & Swap
8	memory=14GB
9	# Swap nằm trong VHDX trên SSD, không tính vào commit của Windows
10	swap=16GB
11	
12	# 2. CPU: 10 vCPU cho WSL, chừa 6 luồng cho Windows + luồng I/O Hyper-V phục vụ chính VM.
13	# Nếu cần build song song mạnh hơn có thể trả về 12.
14	processors=10
15	
16	# 3. Ảo hóa & Đồ họa
17	nestedVirtualization=true
18	guiApplications=true
19	
20	# 4. Mạng NAT ổn định cho Remote IDE, Antigravity và \\wsl.localhost
21	networkingMode=nat
22	localhostForwarding=true
23	
24	# 5. Tham số kernel lúc boot: dự trữ trang liền kề, kswapd thức sớm, nén bộ nhớ chủ động
25	kernelCommandLine=sysctl.vm.min_free_kbytes=262144 sysctl.vm.watermark_scale_factor=150 sysctl.vm.compaction_proactiveness=60
26	
27	[experimental]
28	# Trả page cache về Windows khi rảnh mà không ballooning dần (gradual)
29	autoMemoryReclaim=dropcache
30	# Tự động co giãn đĩa ảo VHDX
31	sparseVhd=true
32

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 70,
  "limit": 60,
  "pages": ""
}
```

**Response:**

70	        <td>Nhượng giờ cho firewall</td></tr>
71	    <tr><td>DB</td><td>repmgr automatic failover</td><td>Streaming + <strong>promote có script + DB VIP</strong>, giữ PITR</td>
72	        <td>Giảm 3h, độ khó 4.5→4.2, vẫn chứng minh RPO=0</td></tr>
73	    <tr><td>Session</td><td>Redis + sticky cookie</td><td>Session trong DB, không sticky</td>
74	        <td>Giảm 2h; khai báo thẳng là trade-off trong báo cáo</td></tr>
75	</table>
76	
77	<h2>2. Hạ tầng: một máy host + Tailscale control plane</h2>
78	<table>
79	    <tr><th></th><th>Máy HÙNG — i5-12500H, 32 GB</th><th>Máy BẢO — i7-11800H, 16 GB</th></tr>
80	    <tr><td>Vai trò</td><td><strong>Toàn bộ lab</strong>: 12 VM, mọi vùng mạng</td>
81	        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
82	    <tr><td>VM</td>
83	        <td>opns1, opns2, lb1, lb2, web1, web2, pg1, pg2, obs, ca, attacker, sensor</td>
84	        <td><strong>0 VM</strong></td></tr>
85	    <tr><td>Ram</td>
86	        <td>2 + 2 + 0.5 + 0.5 + 1 + 1 + 1.5 + 1.5 + 2.5 + 0.5 + 2 + 1.5 = <strong>17 GB</strong> khi bật đủ;<br>
87	            steady state ~13.5 GB (attacker + sensor chỉ bật khi test)</td>
88	        <td>~2 GB cho WSL2 + Tailscale + trình duyệt</td></tr>
89	    <tr><td>Phần mềm cần cài</td><td>VMware Workstation Pro, OpenSSH Server, Tailscale</td><td>Tailscale, WSL2 + Ansible, Git</td></tr>
90	    <tr><td>Chi phí thêm</td><td colspan="2"><strong>0 đồng</strong> — không cáp, không USB-Ethernet adapter, không switch</td></tr>
91	</table>
92	
93	<h3>2.1 Bố trí vmnet (không còn bridged)</h3>
94	<pre>
95	MÁY HÙNG — 6 vmnet, TẤT CẢ là private/host-only trong host, không cái nào ra mạng vật lý:
96	
97	  vmnet-wan      10.0.0.0/24     : opns1 eth0 .1, opns2 eth0 .2, CARP VIP .100,
98	                                  attacker .20, sensor .21        ← "Internet" giả lập
99	  vmnet-sync     192.168.50.0/24 : opns1 ↔ opns2 (pfsync + cfgsync)
100	  vmnet-dmzfront 192.168.20.0/24 : opns eth1, lb1 .10, lb2 .11, Keepalived VIP .100
101	  vmnet-dmzapp   192.168.21.0/24 : opns eth2, web1 .21, web2 .22
102	  vmnet-trusted  192.168.30.0/24 : opns eth3, pg1 .11, pg2 .12, DB VIP .100
103	  vmnet-mgmt     192.168.99.0/24 : opns eth4, GUI VIP .100, obs .30, ca .31
104	
105	MÁY BẢO — không có vmnet nào tham gia lab:
106	  Tailscale 100.64.x.x  ──ssh──►  host Windows của Hùng (100.64.x.x)
107	                                    │ host có adapter trên MỖI vmnet ở trên
108	                                    └─► tới được mọi VM mà không cần route
109	</pre>
110	<div class="kpi">
111	<strong>Điểm làm cho phương án này chạy được:</strong> ProxyJump không định tuyến gói tin — nó mở một kết nối TCP
112	<em>từ host của Hùng</em> tới VM đích. Vì host OS vốn đã nằm trên từng vmnet (adapter VMnet1/VMnet8 tương ứng),
113	nó tới được mọi VM mà không cần advertise route, không cần IP forwarding, không cần RRAS. Đây là lý do bỏ được cáp
114	mà không phải đánh đổi cấu hình lab.
115	</div>
116	
117	<h3>2.2 Quyền truy cập từ máy Bảo</h3>
118	<pre>
119	# Liệt kê VM đang chạy và bật một VM từ xa
120	ssh hung@100.64.x.x '"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list'
121	ssh hung@100.64.x.x '"...\vmrun.exe" start "D:\lab\lb1\lb1.vmx" nogui'
122	
123	# Vào VM bất kỳ — dùng host làm jump hop
124	ssh -J hung@100.64.x.x ops@192.168.20.10          # lb1
125	ssh -J hung@100.64.x.x ops@192.168.30.11          # pg1
126	
127	# ansible.cfg — một dòng cho toàn bộ playbook
128	[ssh_connection]
129	ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ProxyJump=hung@100.64.x.x

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 180,
  "limit": 150,
  "pages": ""
}
```

**Response:**

180	    <tr><td>7</td><td><strong>Đường quản trị không qua firewall — phải nói rõ</strong></td>
181	        <td>Đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter.
182	        Ghi thẳng vào báo cáo (B10) thay vì để giám khảo phát hiện; nếu không, nó trông như một lỗ hổng bạn không biết mình có.</td></tr>
183	</table>
184	
185	<h3>2.5 Cái được và cái mất so với phương án 2 cáp</h3>
186	<table>
187	    <tr><th></th><th>v4.1 — 2 cáp</th><th>v4.2 — Tailscale</th></tr>
188	    <tr><td>Chi phí phần cứng</td><td>2 USB-Ethernet adapter + 2 cáp (~500k)</td><td><strong>0đ</strong></td></tr>
189	    <tr><td>Giờ GĐ0</td><td>12h</td><td><strong>8.5h</strong></td></tr>
190	    <tr><td>Việc của Bảo chạy độc lập</td><td>~20h (obs/ca/attacker trên máy mình)</td><td>~10h (chỉ code + báo cáo; mọi test cần lab bật)</td></tr>
191	    <tr><td>Độ khó attack validation</td><td>4.6 (bằng chứng từ host vật lý khác)</td><td>4.2 (bằng chứng từ vmnet riêng, cùng host)</td></tr>
192	    <tr><td>NFR-13 giám sát ngoài vùng bảo vệ</td><td>Đúng nghĩa vật lý</td><td>Chỉ đúng nghĩa <em>logic</em> — obs ở vùng MGMT riêng, không node DMZ/TRUSTED nào ghi được</td></tr>
193	    <tr><td>Lỗi ghép nối giữa 2 máy</td><td>Có (adapter, driver, bridged Wi-Fi, client isolation)</td><td><strong>Không còn</strong></td></tr>
194	    <tr><td>Tổng giờ</td><td>120h</td><td><strong>115.5h</strong> (82% quỹ 140h)</td></tr>
195	</table>
196	
197	<h3>2.6 Quy ước vận hành</h3>
198	<ul>
199	    <li>Máy Hùng: Power plan High performance, <em>never sleep</em> khi cắm điện; <code>sshd</code> automatic; Tailscale autostart.</li>
200	    <li>Không ai tự <code>poweroff</code> VM của người kia. Lệnh tắt cả lab là lệnh chung, báo trước. Ghi rõ trong <code>CONTRIBUTING.md</code>.</li>
201	    <li>NTP: một source chung cho 12 VM + 2 host OS. PITR và đối chiếu log đa nguồn đều theo timestamp.</li>
202	    <li>Snapshot: <code>clean</code> (ngày 1), <code>green</code> (cuối mỗi ngày), <code>before-&lt;T-xx&gt;</code> (trước mỗi test phá),
203	        <code>IPS-off</code> (trước khi bật inline IPS).</li>
204	    <li>Việc nào cần bật attacker/sensor thì bật, xong thì tắt — tiết kiệm 3.5 GB RAM và tránh Suricata chạy nền làm nhiễu phép đo.</li>
205	</ul>
206	
207	<h2>3. Kiến trúc 5 vùng</h2>
208	<pre>
209	   MÁY BẢO (0 VM)                                MÁY HÙNG (12 VM, 6 vmnet riêng)
210	  Tailscale 100.64.x ──ssh / ProxyJump──► host Windows + WSL2 Ansible + Git/CI
211	  browser: Grafana, GUI OPNsense (qua ssh -L)
212	
213	   vmnet-wan  10.0.0.0/24 : attacker .20, sensor .21, opns1 .1 / opns2 .2,
214	                            CARP VIP .100  → DNAT 443 về LB VIP
215	   vmnet-sync 192.168.50.0/24 : opns1 ↔ opns2  (pfsync + cfgsync, không ra ngoài)
216	        ┌─────────┬──────────────┬────────────┬────────────────┐
217	   DMZ-FRONT   DMZ-APP        TRUSTED       MGMT
218	   192.168.20  192.168.21     192.168.30    192.168.99
219	   lb1 .10     web1 .21       pg1 .11       opns .1/.2, GUI VIP .100
220	   lb2 .11     web2 .22       pg2 .12       obs .30 (bastion + witness), ca .31
221	   VIP .100    (app+CRS)      DB VIP .100
222	   (Keepalived)               (repmgr + PITR)
223	        IPS inline: WAN + DMZ-FRONT + DMZ-APP
224	</pre>
225	<table>
226	    <tr><th>Vùng</th><th>Dải</th><th>Node</th><th>Nằm ở</th><th>Chính sách mặc định</th><th>IPS</th></tr>
227	    <tr><td>WAN</td><td>10.0.0.0/24</td><td>opns1/2 WAN, CARP .100, attacker .20, sensor .21</td><td>Máy Hùng (vmnet-wan)</td>
228	        <td>Chỉ DNAT 443 → LB VIP + SSH từ <code>ADMIN_SRC</code> → bastion; mọi inbound khác drop</td><td>Có (inline)</td></tr>
229	    <tr><td>DMZ-FRONT</td><td>192.168.20.0/24</td><td>lb1 .10, lb2 .11, VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
230	        <td>lb chỉ được gọi web:8443 và NTP/MGMT theo whitelist</td><td>Có (inline)</td></tr>
231	    <tr><td>DMZ-APP</td><td>192.168.21.0/24</td><td>web1 .21, web2 .22</td><td>Máy Hùng (vmnet riêng)</td>
232	        <td>Chỉ được gọi TRUSTED:5432; <strong>cấm egress ra WAN</strong></td><td>Có (inline)</td></tr>
233	    <tr><td>TRUSTED</td><td>192.168.30.0/24</td><td>pg1 .11, pg2 .12, DB VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
234	        <td>Chỉ nhận từ alias <code>APP_NODES</code>; cấm ra WAN</td><td>Không (giữ hiệu năng)</td></tr>
235	    <tr><td>MGMT</td><td>192.168.99.0/24</td><td>opns .1/.2, GUI VIP .100, obs .30, ca .31</td><td>Máy Hùng (vmnet-mgmt)</td>
236	        <td>GUI + SSH chỉ từ MGMT/bastion; obs được phép scrape các vùng</td><td>Không</td></tr>
237	</table>
238	<div class="note">
239	<strong>Hai segment xuyên máy là WAN và MGMT — và chỉ hai cái đó.</strong> Nguyên tắc: một segment chỉ được trải
240	qua 2 máy khi nó <em>không</em> chứa node nào mà attacker có thể lợi dụng để đi vòng qua perimeter. WAN là vùng
241	không tin cậy (mọi thứ đi qua nó đều bị kiểm), MGMT là vùng quản trị có kiểm soát (bastion + <code>ADMIN_SRC</code>).
242	DMZ-FRONT/DMZ-APP/TRUSTED bắt buộc ở lại trong một host — xem 2.4.
243	</div>
244	
245	<h2>4. Ràng buộc phi chức năng (14 điều, firewall-first)</h2>
246	<table>
247	    <tr><th>Mã</th><th>Ràng buộc</th><th>Ngưỡng phải đạt</th></tr>
248	    <tr><td>NFR-01</td><td>CARP failover</td><td>Đổi master ≤ 5 s; <strong>session TCP đang mở không đứt</strong> (pfsync hoạt động) — đo bằng <code>iperf3</code> + <code>ssh</code> đang chạy</td></tr>
249	    <tr><td>NFR-02</td><td>Áp dụng chính sách dưới tải</td><td>Thêm/sửa rule qua API: 0 gián đoạn, 0 lỗi 5xx, không cắt state đang có</td></tr>
250	    <tr><td>NFR-03</td><td>Default-deny tuyệt đối</td><td>Mọi permit phải tham chiếu <strong>alias</strong>, không hardcode IP đơn; 24 combo (zone,dst,port) kiểm tự động, khớp 100%</td></tr>
251	    <tr><td>NFR-04</td><td>IPS fail-closed</td><td>Khi Suricata/NFQUEUE chết, traffic <strong>không</strong> được flow-through im lặng; phải có alert + test chứng minh hành vi đã chọn</td></tr>
252	    <tr><td>NFR-05</td><td>Bằng chứng cho mọi rule</td><td>Mỗi rule có <code>POLICY-ID</code> + counter; báo cáo nêu được rule nào đã được kích hoạt bởi kịch bản nào</td></tr>
253	    <tr><td>NFR-06</td><td>Chống flood ở perimeter</td><td>State table limit / max src conn: SYN flood 50k pkt/s không làm sập dịch vụ, VIP vẫn nổi</td></tr>
254	    <tr><td>NFR-07</td><td>Không có egress</td><td>DMZ-APP và TRUSTED không tự ra WAN được (chặn C2/exfil); kiểm bằng reverse shell mô phỏng</td></tr>
255	    <tr><td>NFR-08</td><td>Log tập trung + tương quan</td><td>Firewall + IPS + WAF + app về obs, giữ ≥ 7 ngày; tái hiện được 1 chuỗi tấn công hoàn chỉnh bằng log</td></tr>
256	    <tr><td>NFR-09</td><td>Bảo mật truyền thông</td><td>mTLS LB→web; GUI/Giám sát chỉ qua TLS; không plaintext credential</td></tr>
257	    <tr><td>NFR-10</td><td>Khôi phục dữ liệu</td><td>PITR tới timestamp chỉ định, verify bản ghi; RPO = 0 khi mất DB primary</td></tr>
258	    <tr><td>NFR-11</td><td>Hardening thiết bị biên</td><td>Tắt service thừa, GUI TLS + khoá root shell, NTP, backup config có mã hoá, bogon + private-network + anti-spoof bật</td></tr>
259	    <tr><td>NFR-12</td><td>IaC</td><td>Toàn bộ chính sách + config dịch vụ là mã nguồn; rebuild ≤ 30 phút; <code>make check</code> xanh; drift = 0</td></tr>
260	    <tr><td>NFR-13</td><td>Mặt phẳng giám sát ngoài vùng bảo vệ</td><td><code>obs</code>, <code>ca</code>, <code>sensor</code> chạy trên máy khác và không có node nào bị compromise xoá/sửa được bằng chứng về chính nó; kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert</td></tr>
261	    <tr><td>NFR-14</td><td>Không có đường vòng L2</td><td>Không tồn tại segment nào vừa chứa attacker vừa chứa node dịch vụ được bảo vệ; chứng minh bằng <code>arping</code> thất bại từ attacker tới DMZ-FRONT</td></tr>
262	</table>
263	
264	<h2>5. Độ khó theo hạng mục</h2>
265	<table>
266	    <tr><th>Hạng mục</th><th>Độ khó</th><th>Vì sao ở mức đó</th></tr>
267	    <tr><td>OPNsense ×2 + CARP + pfsync + cfgsync</td><td><span class="b45">4.8</span></td><td>HA tầng 2 trên 5 vùng; pfsync giữ state; cfgsync phải không ghi đè tay; failover đo bằng session đang mở</td></tr>
268	    <tr><td>Policy-as-code (YAML → API → apply)</td><td><span class="b45">4.7</span></td><td>Thiết kế mô hình alias/zone + render + áp dụng không gián đoạn + validate 24 combo</td></tr>
269	    <tr><td>Suricata inline IPS + fail-closed</td><td><span class="b45">4.6</span></td><td>NFQUEUE blocking thật, tuning rule, và trả lời câu hỏi "IPS chết thì hệ thống mở hay đóng"</td></tr>
270	    <tr><td>Attack validation + sensor-side evidence</td><td><span class="b45">4.6</span></td><td>Đánh từ ngoài, đối chiếu log phòng thủ với bằng chứng tấn công, map MITRE</td></tr>
271	    <tr><td>Perimeter anti-flood (state limit)</td><td><span class="b45">4.5</span></td><td>Phải đo được state table, không làm sập lab, và giải thích giới hạn</td></tr>
272	    <tr><td>pgBackRest PITR</td><td><span class="b45">4.5</span></td><td>WAL archive + restore theo timestamp + verify dữ liệu</td></tr>
273	    <tr><td>Log correlation + alerting</td><td><span class="b4">4.4</span></td><td>4 nguồn log khác định dạng, tương quan theo thời gian + IP</td></tr>
274	    <tr><td>IaC + CI + rebuild</td><td><span class="b4">4.4</span></td><td>Idempotent trên cả thiết bị biên, drift detection</td></tr>
275	    <tr><td>DB failover + fencing + DB VIP</td><td><span class="b4">4.2</span></td><td>Promote có script, node cũ bị chặn không ghi được</td></tr>
276	    <tr><td>HAProxy + Keepalived VIP</td><td><span class="b4">4.2</span></td><td>TLS, mTLS, health check, VIP multicast</td></tr>
277	    <tr><td>WAF CRS blocking</td><td><span class="b4">4.2</span></td><td>Blocking + ParanoiaLevel 2 + đo false positive</td></tr>
278	    <tr><td>PKI / mTLS</td><td><span class="b4">4.0</span></td><td>CA nội bộ, cert server+client, rotation cơ bản</td></tr>
279	    <tr><td>Web tier + app</td><td><span class="b3">3.6</span></td><td>Đã giản lược (không Redis/rolling deploy) — đây là phần chủ động nhường giờ</td></tr>
280	    <tr><td colspan="2"><strong>TB toàn đề tài</strong></td><td><strong>≈ 4.35 / 5</strong> — cụm firewall–an ninh TB 4.6</td></tr>
281	</table>
282	
283	<h2>6. Phạm vi chi tiết theo 6 cụm</h2>
284	
285	<h3>Cụm A — Nền tảng biên (Hùng)</h3>
286	<ul>
287	    <li>2× OPNsense, mỗi con 5 vNIC; VMXNET3; <code>sync</code> là vmnet host-only riêng cho pfsync + cfgsync (không để pfsync chạy trên WAN).</li>
288	    <li>CARP: vhid duy nhất per zone, 1 con MASTER (advskew thấp), <code>preempt</code> tắt để tránh flap khi demo; theo dõi <code>sysctl net.inet.carp.preempt</code>, <code>ifconfig carp</code>.</li>
289	    <li><strong>pfsync state sync</strong>: bật sync trên mọi interface, kiểm bằng session dài (iperf3/ssh) sống sót qua failover.</li>
290	    <li><strong>cfgsync</strong>: tài khoản sync chỉ có quyền tối thiểu; test sửa tay trên backup → master không bị ghi đè im lặng, và ngược lại phải có cảnh báo drift.</li>
291	    <li>Hardening: GUI HTTPS với cert nội bộ, tắt HTTP, vô hiệu service không dùng, <code>Allow OPT1..</code> tắt, anti-spoofing bật, bogon + private networks, NTP từ MGMT, định kỳ backup <code>config.xml</code> có mã hoá.</li>
292	    <li>Chống flood: <code>states</code> limit, <code>max-src-conn</code>, <code>syncookies</code> (kiểm bằng hping3 từ attacker, ghi lại số state và ảnh hưởng tới VIP).</li>
293	</ul>
294	
295	<h3>Cụm B — Chính sách dạng mã nguồn (Bảo)</h3>
296	<ul>
297	    <li>Mô hình khai báo trong Git: <code>zones</code>, <code>aliases</code> (group objects: <code>APP_NODES</code>, <code>DB_VIP</code>, <code>MGMT_ALLOWED</code>), <code>services</code>, <code>rules[]</code> với <code>id: POL-xxx</code>, <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>.</li>
298	    <li>Renderer Ansible → gọi API OPNsense (alias add/set, rule_filter add/set, <code>apply</code> + <code>filter reload</code>) — reload không cắt state, đó là cơ sở của NFR-02. <em>Cần verify tên endpoint trên đúng phiên bản bạn cài; tài liệu API thay đổi theo release.</em></li>
299	    <li>Idempotency: chạy 2 lần ra cùng một rule set; xoá 1 rule trong YAML → rule biến mất trên thiết bị (không phải cộng dồn).</li>
300	    <li><strong>Policy validator</strong>: quét 24 combo (zone nguồn, đích, port) từ attacker/sensor/web/db, so với YAML, xuất CSV; đồng thời đọc counter của từng rule để chứng minh rule đã thực sự được đi qua.</li>
301	    <li>Drift check: <code>make drift</code> so trạng thái thiết bị với Git, khác biệt = fail CI.</li>
302	</ul>
303	
304	<h3>Cụm C — IPS, WAF và kiểm chứng tấn công</h3>
305	<ul>
306	    <li>Suricata inline trên WAN + DMZ-FRONT + DMZ-APP (OPNsense plugin, chế độ NFQUEUE, blocking), ruleset: emerging-threats + rule tự viết cho hành vi của lab.</li>
307	    <li>Test <strong>fail-closed</strong>: dừng dịch vụ Suricata khi đang có kết nối → xác nhận traffic bị chặn (không phải âm thầm flow-through) và có alert; ghi rõ lựa chọn thiết kế.</li>
308	    <li>CRS blocking trên Apache (mod_security2), ParanoiaLevel 2, file overrides trong Git kèm <code>Reason:</code>.</li>
309	    <li>Bộ tấn công từ <code>attacker</code> — 4 lớp trong harness (B14): (1) nmap/scan → IPS alert; (2) 30 payload web (SQLi/XSS/traversal) → WAF 403 + IPS; (3) SSH brute force → Fail2Ban + alias ban; (4) egress attempt từ web ra WAN → bị chặn. Lớp thứ 5 (SYN flood → state limit) thuộc H10 vì nó là việc của thiết bị biên.</li>
310	    <li><strong>Sensor</strong> (VM riêng trên vmnet-wan) chạy tcpdump + Zeek độc lập: với mỗi tấn công, đối chiếu "tôi đã gửi gì" và "hệ thống phòng thủ ghi nhận gì"; bảng lệch nhau là nội dung báo cáo có giá trị nhất.</li>
311	    <li>Map MITRE ATT&amp;CK: T1046 (scan), T1190 (exploit public app), T1110 (brute force), T1048/T1071 (egress/C2), T1562.110 (impair defenses — chính là test fail-closed).</li>
312	</ul>
313	
314	<h3>Cụm D — Tầng dịch vụ được bảo vệ (Bảo)</h3>
315	<ul>
316	    <li>HAProxy ×2: TLS termination, mTLS xuống web, health check <code>/healthz</code>, stats bind MGMT.</li>
317	    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
318	    <li>App 4 endpoint: <code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code> (ghi DB), <code>/session</code>; session lưu trong PostgreSQL (chứng minh app stateless mà không cần Redis).</li>
319	    <li>Web chỉ nhận kết nối có client cert; không truy cập Internet.</li>
320	</ul>
321	
322	<h3>Cụm E — Tầng dữ liệu + khôi phục (Hùng)</h3>
323	<ul>
324	    <li>PostgreSQL 16 ×2, streaming replication, <code>synchronous_commit = on</code>, <code>hostssl</code> + scram.</li>
325	    <li>Failover bằng script <code>promote.sh</code>: di chuyển <code>DB_VIP 192.168.30.100</code> sang standby + đẩy alias firewall cập nhật + <strong>fence</strong> node cũ (stop + rule chặn 5432 từ nó).</li>
326	    <li>App không đổi connection string (luôn trỏ DB_VIP) — đây là điểm khác biệt so với v3 và là thứ phải chứng minh được.</li>
327	    <li>pgBackRest: full + incremental + WAL archive lên obs (repo NFS/ssh), <strong>diễn tập PITR</strong> tới timestamp và verify 3 bản ghi mốc.</li>
328	</ul>
329

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command \"$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write-Output '--- WSL STATUS ---'; & wsl.exe --status 2>&1 | ForEach-Object { $_.ToString() }; Write-Output '--- WSL VERSION ---'; & wsl.exe --version 2>&1 | ForEach-Object { $_.ToString() }; Write-Output '--- DISTROS ---'; & wsl.exe --list --verbose 2>&1 | ForEach-Object { $_.ToString() }\"",
  "description": "Xác nhận distro và phiên bản WSL bằng PowerShell",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
At line:1 char:64
+ ...  [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write ...
+                                                                  ~
An expression was expected after '('.
At line:1 char:162
+ ...  & wsl.exe --status 2>&1 | ForEach-Object { extglob.ToString() }; Wri ...
+                                                                  ~
An expression was expected after '('.
At line:1 char:264
+ ... & wsl.exe --version 2>&1 | ForEach-Object { extglob.ToString() }; Wri ...
+                                                                  ~
An expression was expected after '('.
At line:1 char:369
+ ... wsl.exe --list --verbose 2>&1 | ForEach-Object { extglob.ToString() }
+                                                                       ~
An expression was expected after '('.
    + CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : ExpectedExpression

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command \"Write-Output '--- WSL FEATURE ---'; Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform | Select-Object FeatureName,State; Write-Output '--- HYPERVISOR ---'; Get-CimInstance Win32_ComputerSystem | Select-Object HypervisorPresent; Write-Output '--- PAGEFILE ---'; Get-CimInstance Win32_PageFileUsage | Select-Object Name,AllocatedBaseSize,CurrentUsage; Write-Output '--- ADAPTERS ---'; Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object Name,InterfaceDescription,LinkSpeed\"",
  "description": "Kiểm tra tính năng ảo hóa và bộ nhớ hệ thống",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- WSL FEATURE ---
Get-WindowsOptionalFeature : Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 
'FeatureName'. Specified method is not supported.
At line:1 char:85
+ ... FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform  ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Get-WindowsOptionalFeature], ParameterBindingException
    + FullyQualifiedErrorId : CannotConvertArgument,Microsoft.Dism.Commands.GetWindowsOptionalFeatureCommand
 
--- HYPERVISOR ---

HypervisorPresent
-----------------
             True
--- PAGEFILE ---
                 
--- ADAPTERS ---

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command \"Write-Output '--- PROJECT FILES ---'; Get-ChildItem -Force -File -Recurse -Depth 2 | Select-Object FullName,Length,LastWriteTime; Write-Output '--- TOP LEVEL ---'; Get-ChildItem -Force | Select-Object Name,Mode,Length,LastWriteTime\"",
  "description": "Liệt kê file và thư mục dự án hiện tại",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- PROJECT FILES ---

FullName                       Length LastWriteTime       
--------                       ------ -------------       
D:\Lab\ha-lb-security-lab.html  67298 11/7/2026 9:50:15 AM
--- TOP LEVEL ---
                                67298 11/7/2026 9:50:15 AM

#### Thinking

**Planning WSL environment survey with linked files****Investigating Bash quoting issues with PowerShell commands****Planning system info retrieval with PowerShell commands**

#### Thinking

**Planning WSL environment inspection**

Mình đã thấy cấu hình `.wslconfig` đang cấp 14 GB RAM, 10 vCPU và swap 16 GB; đồng thời phát hiện một vài lệnh PowerShell bị Git Bash nuốt biến do quoting, nên kết quả distro/CPU chưa đáng tin. Mình sẽ chạy lại bằng quoting an toàn và kiểm tra cả khả năng truy cập filesystem/network của WSL.

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe --status; wsl.exe --version; wsl.exe --list --verbose",
  "description": "Đọc trạng thái phiên bản và danh sách WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

[Binary output: 856 bytes]

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- COMPUTER ---\"; Get-CimInstance Win32_ComputerSystem | Format-List Manufacturer,Model,TotalPhysicalMemory; Write-Output \"--- CPU ---\"; Get-CimInstance Win32_Processor | Format-List Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed; Write-Output \"--- OS ---\"; Get-CimInstance Win32_OperatingSystem | Format-List Caption,Version,BuildNumber,FreePhysicalMemory,LastBootUpTime; Write-Output \"--- GPU ---\"; Get-CimInstance Win32_VideoController | Format-List Name,AdapterRAM,DriverVersion'",
  "description": "Đọc thông tin phần cứng Windows chính xác",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- COMPUTER ---


Manufacturer        : Acer
Model               : Nitro AN515-58
TotalPhysicalMemory : 34049417216



--- CPU ---


Name                      : 12th Gen Intel(R) Core(TM) i5-12500H
NumberOfCores             : 12
NumberOfLogicalProcessors : 16
MaxClockSpeed             : 3100



--- OS ---


Caption            : Microsoft Windows 11 Pro
Version            : 10.0.26200
BuildNumber        : 26200
FreePhysicalMemory : 4499544
LastBootUpTime     : 11/6/2026 7:14:57 PM



--- GPU ---


Name          : IddSampleDriver Device
AdapterRAM    : 
DriverVersion : 17.57.32.886

Name          : IddSampleDriver Device
AdapterRAM    : 
DriverVersion : 17.57.32.886

Name          : Intel(R) Iris(R) Xe Graphics
AdapterRAM    : 1073741824
DriverVersion : 31.0.101.5081

Name          : NVIDIA GeForce RTX 3050 Laptop GPU
AdapterRAM    : 4293918720
DriverVersion : 32.0.16.1714

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- WSL FEATURES ---\"; Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform | Format-Table FeatureName,State -AutoSize; Write-Output \"--- HYPERVISOR ---\"; Get-CimInstance Win32_ComputerSystem | Format-List HypervisorPresent; Write-Output \"--- PAGEFILE ---\"; Get-CimInstance Win32_PageFileUsage | Format-Table Name,AllocatedBaseSize,CurrentUsage -AutoSize'",
  "description": "Kiểm tra tính năng WSL và bộ nhớ ảo hóa",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- WSL FEATURES ---
Get-WindowsOptionalFeature : Cannot convert 'System.Object[]' to the type 'System.String' required by parameter 
'FeatureName'. Specified method is not supported.
At line:1 char:86
+ ... FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform  ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Get-WindowsOptionalFeature], ParameterBindingException
    + FullyQualifiedErrorId : CannotConvertArgument,Microsoft.Dism.Commands.GetWindowsOptionalFeatureCommand
 
--- HYPERVISOR ---


HypervisorPresent : True



--- PAGEFILE ---

Name            AllocatedBaseSize CurrentUsage
----            ----------------- ------------
D:\pagefile.sys             32768         2756

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VOLUMES ---\"; Get-Volume | Where-Object DriveLetter | Format-Table DriveLetter,FileSystem,Size,SizeRemaining,HealthStatus -AutoSize; Write-Output \"--- WSL VHDX ---\"; Get-ChildItem -Path \"$env:LOCALAPPDATA\\Packages\" -Filter ext4.vhdx -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime'",
  "description": "Kiểm tra dung lượng ổ và đĩa WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
--- VOLUMES ---

DriveLetter FileSystem          Size SizeRemaining HealthStatus
----------- ----------          ---- ------------- ------------
          C NTFS        511000440832   88974540800 Healthy     
          D NTFS       1000203087872  327389753344 Healthy     


--- WSL VHDX ---

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- ADAPTERS ---\"; Get-NetAdapter | Where-Object Status -eq \"Up\" | Format-Table Name,InterfaceDescription,LinkSpeed,MacAddress -AutoSize; Write-Output \"--- IP CONFIG ---\"; Get-NetIPConfiguration | Where-Object NetAdapter.Status -eq \"Up\" | Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer'",
  "description": "Kiểm tra card mạng và cấu hình IP host",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- ADAPTERS ---

Name                               InterfaceDescription                                               LinkSpeed MacAddr
                                                                                                                ess    
----                               --------------------                                               --------- -------
vEthernet (WSL (Hyper-V firewall)) Hyper-V Virtual Ethernet Adapter #2                                10 Gbps   00-1...
VMware Network Adapter VMnet1      VMware Virtual Ethernet Adapter for VMnet1                         100 Mbps  00-5...
Wi-Fi                              Killer(R) Wi-Fi 6 AX1650i 160MHz Wireless Network Adapter (201NGW) 540 Mbps  02-A...
VMware Network Adapter VMnet8      VMware Virtual Ethernet Adapter for VMnet8                         100 Mbps  00-5...
vEthernet (Default Switch)         Hyper-V Virtual Ethernet Adapter                                   10 Gbps   00-1...


--- IP CONFIG ---

#### Thinking

**Exploring methods to read WSL distro names****Testing UTF-16LE to UTF-8 conversion for WSL output**

#### Thinking

**Assessing WSL memory usage and distro details**

Kết quả host đã khá rõ: máy có 32 GB RAM, i5-12500H/16 luồng, RTX 3050 4 GB, còn khoảng 4.5 GB RAM tự do; VMware và WSL đều đang có adapter hoạt động. Mình sẽ lấy tên distro, kernel, mức dùng RAM/đĩa/mạng/GPU bên trong WSL và mức sử dụng hiện tại của `vmmemWSL`.

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe --list --quiet | iconv -f UTF-16LE -t UTF-8 2>/dev/null || wsl.exe --list --quiet",
  "description": "Lấy tên các distro WSL đã cài",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

[Binary output: 74 bytes]

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- RUNNING WSL ---\"; wsl.exe --list --running --verbose; Write-Output \"--- DEFAULT ---\"; wsl.exe --status; Write-Output \"--- VMMEM ---\"; Get-Process -Name vmmem* -ErrorAction SilentlyContinue | Format-Table ProcessName,Id,CPU,WorkingSet64,PrivateMemorySize64 -AutoSize; Write-Output \"--- WSL SERVICE ---\"; Get-Service WslService,LxssManager -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -AutoSize'",
  "description": "Kiểm tra distro đang chạy và tiến trình WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
[Binary output: 822 bytes]

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe -e sh -lc 'printf \"%s\\n\" \"--- KERNEL ---\"; uname -a; printf \"%s\\n\" \"--- OS ---\"; cat /etc/os-release; printf \"%s\\n\" \"--- CPU ---\"; nproc; grep -m1 \"model name\" /proc/cpuinfo; printf \"%s\\n\" \"--- MEMORY ---\"; free -h; printf \"%s\\n\" \"--- FILESYSTEM ---\"; df -hT; printf \"%s\\n\" \"--- MOUNTS ---\"; mount | grep -E \" on /mnt/[cd] | on / type\"; printf \"%s\\n\" \"--- GPU ---\"; test -e /dev/dxg && printf \"%s\\n\" \"/dev/dxg present\" || printf \"%s\\n\" \"/dev/dxg absent\"; command -v nvidia-smi || true; nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader 2>/dev/null || true; printf \"%s\\n\" \"--- NETWORK ---\"; ip -brief addr; ip route'",
  "description": "Kiểm tra kernel tài nguyên filesystem GPU và mạng trong WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- KERNEL ---
Linux Iphone 6.18.54.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Tue Oct  6 19:13:07 UTC 2026 x86_64 GNU/Linux
--- OS ---
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
--- CPU ---
10
model name	: 12th Gen Intel(R) Core(TM) i5-12500H
--- MEMORY ---
               total        used        free      shared  buff/cache   available
Mem:            13Gi       4.0Gi       1.7Gi       6.7Mi       9.5Gi       9.7Gi
Swap:           16Gi       5.4Mi        15Gi
--- FILESYSTEM ---
Filesystem     Type      Size  Used Avail Use% Mounted on
none           overlay   6.9G     0  6.9G   0% /usr/lib/modules/6.18.54.1-microsoft-standard-WSL2
/dev/sdb       ext4       97M   97M     0 100% /usr/lib/linux-tools/6.18.54.1-microsoft-standard-WSL2
none           tmpfs     6.9G  4.0K  6.9G   1% /mnt/wsl
drivers        9p        476G  394G   83G  83% /usr/lib/wsl/drivers
/dev/sdd       ext4     1007G   59G  898G   7% /
none           tmpfs     6.9G   40K  6.9G   1% /mnt/wslg
none           overlay   6.9G     0  6.9G   0% /usr/lib/wsl/lib
rootfs         rootfs    6.9G  3.4M  6.9G   1% /init
none           devtmpfs  6.9G     0  6.9G   0% /dev
none           tmpfs     6.9G  480K  6.9G   1% /run
none           tmpfs     6.9G     0  6.9G   0% /run/lock
none           tmpfs     6.9G     0  6.9G   0% /run/shm
none           overlay   6.9G   80K  6.9G   1% /mnt/wslg/versions.txt
none           overlay   6.9G   80K  6.9G   1% /mnt/wslg/doc
C:\            9p        476G  394G   83G  83% /mnt/c
D:\            9p        932G  627G  305G  68% /mnt/d
tmpfs          tmpfs     2.0G     0  2.0G   0% /dev/shm/pcn_cache
none           tmpfs     1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs          tmpfs     1.4G  8.0M  1.4G   1% /run/user/0
--- MOUNTS ---
/dev/sdd on / type ext4 (rw,relatime,discard,errors=remount-ro,data=ordered)
C:\ on /mnt/c type 9p (rw,noatime,aname=drvfs;path=C:\;uid=0;gid=0;metadata;umask=22;fmask=11;case=off;symlinkroot=/mnt/,cache=0x5,access=client,msize=65536,trans=fd,rfd=6,wfd=6)
D:\ on /mnt/d type 9p (rw,noatime,aname=drvfs;path=D:\;uid=0;gid=0;metadata;umask=22;fmask=11;case=off;symlinkroot=/mnt/,cache=0x5,access=client,msize=65536,trans=fd,rfd=6,wfd=6)
--- GPU ---
/dev/dxg present
/usr/local/bin/nvidia-smi
NVIDIA GeForce RTX 3050 Laptop GPU, 4096 MiB, 617.14
--- NETWORK ---
lo               UNKNOWN        127.0.0.1/8 10.255.255.254/32 
eth0             UP             172.28.154.216/20 
default via 172.28.144.1 dev eth0 proto kernel onlink 
172.28.144.0/20 dev eth0 proto kernel scope link src 172.28.154.216

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- MEMORY ---\"; Get-Counter \"\\Memory\\Available MBytes\",\"\\Memory\\Committed Bytes\",\"\\Memory\\Commit Limit\" | Select-Object -ExpandProperty CounterSamples | Format-Table Path,CookedValue -AutoSize; Write-Output \"--- VMMEM DETAIL ---\"; Get-Process -Name vmmemWSL -ErrorAction SilentlyContinue | Format-List ProcessName,WorkingSet64,PrivateMemorySize64,VirtualMemorySize64,CPU,StartTime; Write-Output \"--- WSL VHDX LOCATIONS ---\"; Get-ChildItem -Path \"$env:LOCALAPPDATA\\Packages\" -Filter ext4.vhdx -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime'",
  "description": "Đo commit memory và footprint hiện tại của WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
--- MEMORY ---

Path                             CookedValue
----                             -----------
\\iphone\memory\available mbytes        4416
\\iphone\memory\committed bytes  46177837056
\\iphone\memory\commit limit     68409155584


--- VMMEM DETAIL ---


ProcessName         : vmmemWSL
WorkingSet64        : 2730995712
PrivateMemorySize64 : 13704241152
VirtualMemorySize64 : 19360841728
CPU                 : 
StartTime           : 



--- WSL VHDX LOCATIONS ---

> Tool failed.

#### Thinking

**Investigating WSL binary output issue****Diagnosing WSL output encoding and querying distros**

#### Thinking

**Querying WSL configuration via registry and commands**

Một số lệnh `wsl.exe` trả output Unicode khiến lớp terminal hiển thị nhị phân, nhưng không phải lỗi môi trường. Mình chuyển sang đọc registry và chạy từng phép đo nhỏ trong distro để tránh kết luận sai; hiện footprint WSL khoảng 2.7 GB working set, còn giới hạn commit toàn host đã khá căng.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-ChildItem \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\" -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PSPath } | Select-Object DistributionName,Version,BasePath,DefaultUid | Format-List'",
  "description": "Đọc registry để xác định distro WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

DistributionName : kali-linux
Version          : 2
BasePath         : D:\WSL\kali-linux
DefaultUid       : 1000

DistributionName : archlinux
Version          : 2
BasePath         : D:\WSL\archlinux
DefaultUid       : 0

DistributionName : Ubuntu-26.04
Version          : 2
BasePath         : D:\WSL\Ubuntu-26.04
DefaultUid       : 0

#### Tool: Bash

**Input:**

```json
{
  "command": "cmd.exe /c \"chcp 65001>nul & wsl.exe --list --verbose\"",
  "description": "Liệt kê distro WSL với UTF-8",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Microsoft Windows [Version 10.0.26200.6584]
(c) Microsoft Corporation. All rights reserved.

D:\Lab>

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VMWARE ---\"; Get-Process vmware*,vmx* -ErrorAction SilentlyContinue | Format-Table ProcessName,Id,CPU,WorkingSet64,PrivateMemorySize64 -AutoSize; Write-Output \"--- WSL RELATED ---\"; Get-Process *wsl*,vmmem* -ErrorAction SilentlyContinue | Format-Table ProcessName,Id,WorkingSet64,PrivateMemorySize64 -AutoSize; Write-Output \"--- SERVICES ---\"; Get-Service vmms,vmcompute,WslService,LxssManager -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -AutoSize'",
  "description": "Đo tài nguyên VMware và tiến trình liên quan WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
--- VMWARE ---

ProcessName              Id CPU WorkingSet64 PrivateMemorySize64
-----------              -- --- ------------ -------------------
vmware-authd           6416         12775424             4382720
vmware-usbarbitrator64 6476         14671872             3350528


--- WSL RELATED ---

ProcessName      Id WorkingSet64 PrivateMemorySize64
-----------      -- ------------ -------------------
vmmemCmZygote  9392         8192           821293056
vmmemWSL      12832   1701232640         13698686976
wsl            4256     12169216             3006464
wsl           25308      9555968             1880064
wsl           28364     13000704             3239936
wsl           30064     13180928             3031040
wsl           32052      7540736             1540096
wslhost         340     12898304             2760704
wslhost        5472     11993088             2732032
wslhost       19464     12120064             3108864
wslhost       21564     11866112             2707456
wslhost       30912     11874304             2666496
wslrelay       4200     11603968             3301376
wslservice     6688     33198080             9048064


--- SERVICES ---

Name        Status StartType
----        ------ ---------
vmcompute  Running    Manual
vmms       Running Automatic
WslService Running Automatic

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VIRTUALIZATION ---\"; systeminfo.exe | Select-String -Pattern \"Hyper-V Requirements|Virtualization Enabled|Second Level|Data Execution|VM Monitor\"; Write-Output \"--- FEATURES ---\"; foreach ($name in @(\"Microsoft-Windows-Subsystem-Linux\",\"VirtualMachinePlatform\")) { Get-WindowsOptionalFeature -Online -FeatureName $name | Select-Object FeatureName,State }'",
  "description": "Xác nhận ảo hóa phần cứng và feature WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
--- VIRTUALIZATION ---

Hyper-V Requirements:          A hypervisor has been detected. Features required for Hyper-V will not be displayed.
--- FEATURES ---
Get-WindowsOptionalFeature : The requested operation requires elevation.
At line:1 char:284
+ ... atform")) { Get-WindowsOptionalFeature -Online -FeatureName $name | S ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-WindowsOptionalFeature], COMException
    + FullyQualifiedErrorId : Microsoft.Dism.Commands.GetWindowsOptionalFeatureCommand
 
Get-WindowsOptionalFeature : The requested operation requires elevation.
At line:1 char:284
+ ... atform")) { Get-WindowsOptionalFeature -Online -FeatureName $name | S ...
+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-WindowsOptionalFeature], COMException
    + FullyQualifiedErrorId : Microsoft.Dism.Commands.GetWindowsOptionalFeatureCommand

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- DISKS ---\"; Get-PhysicalDisk | Format-Table FriendlyName,MediaType,Size,HealthStatus -AutoSize; Write-Output \"--- PARTITIONS ---\"; Get-Partition | Where-Object DriveLetter | Format-Table DriveLetter,DiskNumber,PartitionNumber,Size,Type -AutoSize; Write-Output \"--- WSL PACKAGE DIRS ---\"; Get-ChildItem \"$env:LOCALAPPDATA\\Packages\" -Directory | Where-Object Name -match \"Linux|Ubuntu|Debian|SUSE|Kali\" | Select-Object FullName'",
  "description": "Kiểm tra loại ổ và vị trí package WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- DISKS ---

FriendlyName                   MediaType          Size HealthStatus
------------                   ---------          ---- ------------
NVMe Micron_3400_MTFDKBA512TFH SSD        512110190592 Healthy     
WDC WD10SPZX-00Z10T0           HDD       1000204886016 Healthy     


--- PARTITIONS ---

DriveLetter DiskNumber PartitionNumber          Size Type 
----------- ---------- ---------------          ---- ---- 
          D          1               1 1000203091968 Basic
          C          0               3  511000444928 Basic


--- WSL PACKAGE DIRS ---

FullName                                                                                                   
--------                                                                                                   
C:\Users\Administrator\AppData\Local\Packages\KaliLinux.54290C8133FEE_ey8k8hqnwqnmg                        
C:\Users\Administrator\AppData\Local\Packages\MicrosoftCorporationII.WindowsSubsystemForLinux_8wekyb3d8bbwe

#### Thinking

**Planning WSL distro querying and execution****Exploring WSL status retrieval methods**

#### Thinking

**Checking WSL distro package details****Diagnosing Bash interference with PowerShell commands**

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-ItemProperty \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\" | Format-List *'",
  "description": "Đọc cấu hình mặc định của WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

DefaultVersion      : 2
NatIpAddress        : 172.28.154.216
OOBEComplete        : 1
DefaultDistribution : {8bab1a35-2e91-4c93-b9a7-892b5f0884ee}
PSPath              : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\L
                      xss
PSParentPath        : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion
PSChildName         : Lxss
PSDrive             : HKCU
PSProvider          : Microsoft.PowerShell.Core\Registry

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-ChildItem \"D:\\WSL\" -Directory -ErrorAction SilentlyContinue | ForEach-Object { $p = Join-Path $_.FullName \"ext4.vhdx\"; if (Test-Path $p) { Get-Item $p | Select-Object FullName,Length,LastWriteTime } }'",
  "description": "Đo kích thước VHDX của từng distro",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

FullName                           Length LastWriteTime        
--------                           ------ -------------        
D:\WSL\archlinux\ext4.vhdx    68694310912 11/7/2026 10:15:29 AM
D:\WSL\kali-linux\ext4.vhdx    2873098240 10/29/2026 2:56:36 PM
D:\WSL\Ubuntu-26.04\ext4.vhdx  1719664640 10/29/2026 2:56:36 PM

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe -d kali-linux -- uname -a; wsl.exe -d kali-linux -- cat /etc/os-release",
  "description": "Đọc kernel và OS của Kali WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
wsl: Failed to start the systemd user session for 'sugirl'. See journalctl for more details.
Linux Iphone 6.18.54.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Tue Oct  6 19:13:07 UTC 2026 x86_64 GNU/Linux
cat: 'C:/Program Files/Git/etc/os-release': No such file or directory

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe -d archlinux -- uname -a; wsl.exe -d archlinux -- cat /etc/os-release",
  "description": "Đọc kernel và OS của Arch WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
Linux Iphone 6.18.54.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Tue Oct  6 19:13:07 UTC 2026 x86_64 GNU/Linux
cat: 'C:/Program Files/Git/etc/os-release': No such file or directory

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "wsl.exe -d Ubuntu-26.04 -- uname -a; wsl.exe -d Ubuntu-26.04 -- cat /etc/os-release",
  "description": "Đọc kernel và OS của Ubuntu WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
wsl: Failed to start the systemd user session for 'root'. See journalctl for more details.
Linux Iphone 6.18.54.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Tue Oct  6 19:13:07 UTC 2026 x86_64 GNU/Linux
cat: 'C:/Program Files/Git/etc/os-release': No such file or directory

> Tool failed.

#### Thinking

**Testing WSL path conversion workaround**

#### Thinking

**Testing WSL command path conversion workaround****Querying WSL default distro and registry mapping**

WSL đang có 3 distro WSL2, đều đặt trên ổ HDD `D:`; riêng Arch VHDX đã khoảng 64 GiB, là điểm cần chú ý nếu muốn “đóng gói tối đa” vì dung lượng không đồng nghĩa dung lượng dữ liệu hữu ích và I/O sẽ chậm hơn NVMe `C:`. Hai lần khởi động distro cũng báo lỗi session systemd của user, nên mình sẽ kiểm tra đó là cảnh báo vô hại hay ảnh hưởng đến Ansible/daemon.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-ChildItem \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\" | ForEach-Object { Get-ItemProperty $_.PSPath } | Select-Object DistributionName,Version,BasePath,DefaultUid,DistributionGuid | Format-Table -AutoSize'",
  "description": "Ánh xạ distro WSL và distro mặc định",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

DistributionName Version BasePath            DefaultUid DistributionGuid
---------------- ------- --------            ---------- ----------------
kali-linux             2 D:\WSL\kali-linux         1000                 
archlinux              2 D:\WSL\archlinux             0                 
Ubuntu-26.04           2 D:\WSL\Ubuntu-26.04          0

#### Tool: Bash

**Input:**

```json
{
  "command": "MSYS_NO_PATHCONV=1 wsl.exe -d kali-linux -- sh -c 'printf \"--- OS ---\\n\"; cat /etc/os-release; printf \"--- ID ---\\n\"; id; printf \"--- MEMORY ---\\n\"; free -h; printf \"--- DISK ---\\n\"; df -hT / /mnt/c /mnt/d; printf \"--- SYSTEMD ---\\n\"; systemctl is-system-running 2>&1 || true; printf \"--- SERVICES ---\\n\"; systemctl list-units --type=service --state=running --no-legend 2>/dev/null | wc -l'",
  "description": "Đo trạng thái và dịch vụ trong Kali WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

sh: 1: printf: Illegal option --
PRETTY_NAME="Kali GNU/Linux Rolling"
NAME="Kali GNU/Linux"
VERSION_ID="2026.3"
VERSION="2026.3"
VERSION_CODENAME=kali-rolling
ID=kali
ID_LIKE=debian
HOME_URL="https://www.kali.org/"
SUPPORT_URL="https://forums.kali.org/"
BUG_REPORT_URL="https://bugs.kali.org/"
ANSI_COLOR="1;31"
sh: 1: printf: Illegal option --
uid=1000(sugirl) gid=1000(sugirl) groups=1000(sugirl),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users)
sh: 1: printf: Illegal option --
               total        used        free      shared  buff/cache   available
Mem:            13Gi       4.0Gi       1.3Gi       7.4Mi       9.8Gi       9.6Gi
Swap:           16Gi       5.4Mi        15Gi
sh: 1: printf: Illegal option --
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sde       ext4 1007G  1.8G  954G   1% /
C:\            9p    476G  394G   83G  83% /mnt/c
D:\            9p    932G  627G  305G  68% /mnt/d
sh: 1: printf: Illegal option --
degraded
sh: 1: printf: Illegal option --
7

#### Tool: Bash

**Input:**

```json
{
  "command": "MSYS_NO_PATHCONV=1 wsl.exe -d archlinux -- sh -c 'printf \"--- OS ---\\n\"; cat /etc/os-release; printf \"--- ID ---\\n\"; id; printf \"--- MEMORY ---\\n\"; free -h; printf \"--- DISK ---\\n\"; df -hT / /mnt/c /mnt/d; printf \"--- SYSTEMD ---\\n\"; systemctl is-system-running 2>&1 || true; printf \"--- SERVICES ---\\n\"; systemctl list-units --type=service --state=running --no-legend 2>/dev/null | wc -l'",
  "description": "Đo trạng thái và dịch vụ trong Arch WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
uid=0(root) gid=0(root) groups=0(root)
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
               total        used        free      shared  buff/cache   available
Mem:            13Gi       4.1Gi       1.3Gi       7.4Mi       9.8Gi       9.6Gi
Swap:           16Gi       5.4Mi        15Gi
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdd       ext4 1007G   59G  898G   7% /
C:\            9p    476G  394G   83G  83% /mnt/c
D:\            9p    932G  627G  305G  68% /mnt/d
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
running
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
10

#### Tool: Bash

**Input:**

```json
{
  "command": "MSYS_NO_PATHCONV=1 wsl.exe -d Ubuntu-26.04 -- sh -c 'printf \"--- OS ---\\n\"; cat /etc/os-release; printf \"--- ID ---\\n\"; id; printf \"--- MEMORY ---\\n\"; free -h; printf \"--- DISK ---\\n\"; df -hT / /mnt/c /mnt/d; printf \"--- SYSTEMD ---\\n\"; systemctl is-system-running 2>&1 || true; printf \"--- SERVICES ---\\n\"; systemctl list-units --type=service --state=running --no-legend 2>/dev/null | wc -l'",
  "description": "Đo trạng thái và dịch vụ trong Ubuntu WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

wsl: Failed to start the systemd user session for 'root'. See journalctl for more details.
sh: 1: printf: Illegal option --
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo
sh: 1: printf: Illegal option --
uid=0(root) gid=0(root) groups=0(root)
sh: 1: printf: Illegal option --
               total        used        free      shared  buff/cache   available
Mem:            13Gi       4.1Gi       1.1Gi       7.4Mi       9.9Gi       9.5Gi
Swap:           16Gi       5.4Mi        15Gi
sh: 1: printf: Illegal option --
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdf       ext4 1007G  1.5G  955G   1% /
C:\            9p    476G  394G   83G  83% /mnt/c
D:\            9p    932G  627G  305G  68% /mnt/d
sh: 1: printf: Illegal option --
starting
sh: 1: printf: Illegal option --
14

#### Tool: Bash

**Input:**

```json
{
  "command": "MSYS_NO_PATHCONV=1 wsl.exe -d archlinux -- sh -c 'printf \"--- NETWORK ---\\n\"; ip -brief addr; ip route; printf \"--- RESOLV ---\\n\"; cat /etc/resolv.conf; printf \"--- GPU ---\\n\"; test -e /dev/dxg && echo /dev/dxg-present || echo /dev/dxg-absent; command -v nvidia-smi || true; nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader 2>&1 || true'",
  "description": "Kiểm tra mạng và GPU trong Arch WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
lo               UNKNOWN        127.0.0.1/8 10.255.255.254/32 
eth0             UP             172.28.154.216/20 
default via 172.28.144.1 dev eth0 proto kernel onlink 
172.28.144.0/20 dev eth0 proto kernel scope link src 172.28.154.216 
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
# This file was automatically generated by WSL. To stop automatic generation of this file, add the following entry to /etc/wsl.conf:
# [network]
# generateResolvConf = false
nameserver 10.255.255.254
search 192.168.1.1
/dev/dxg-present
sh: line 1: printf: --: invalid option
printf: usage: printf [-v var] format [arguments]
/usr/local/bin/nvidia-smi
NVIDIA GeForce RTX 3050 Laptop GPU, 4096 MiB, 617.14

#### Thinking

**Inspecting WSL disk usage and distro states****Analyzing WSL registry, config, and memory usage****Confirming tight WSL memory configuration**

#### Thinking

**Recommending reducing WSL memory when running VMware****Assessing mixed WSL and VMware host environment**

#### Thinking

**Evaluating WSL setup and mount performance****Reviewing WSL resource usage and management options****Planning inspection of WSL configs and tools**

#### Thinking

**Planning WSL distro commands query****Checking WSL tools and system config**

Điểm quan trọng đang nổi lên: WSL hiện đã cấp gần tối đa 14 GB và chiếm gần toàn bộ ngân sách đó khi các distro được gọi, trong khi thiết kế lab cần khoảng 17 GB cho VMware. Mình sẽ kiểm tra nốt tooling (`ansible`, `git`, Docker/Podman, SSH/Tailscale), systemd và VMware để phân biệt “WSL đã sẵn sàng làm control plane” với “WSL nên gánh luôn workload lab”.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-ChildItem \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\" | ForEach-Object { $p = Get-ItemProperty $_.PSPath; [PSCustomObject]@{Key=$_.PSChildName; Name=$p.DistributionName; Base=$p.BasePath; Version=$p.Version; DefaultUid=$p.DefaultUid} } | Format-Table -AutoSize; Write-Output \"--- DEFAULT GUID ---\"; (Get-ItemProperty \"HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Lxss\").DefaultDistribution'",
  "description": "Xác định distro mặc định và GUID tương ứng",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Key                                    Name         Base                Version DefaultUid
---                                    ----         ----                ------- ----------
{4284c1dc-4bc8-4856-8067-7a3569bce74a} kali-linux   D:\WSL\kali-linux         2       1000
{8bab1a35-2e91-4c93-b9a7-892b5f0884ee} archlinux    D:\WSL\archlinux          2          0
{b5571e27-8b27-4dd1-8893-4112e1cd4987} Ubuntu-26.04 D:\WSL\Ubuntu-26.04       2          0


--- DEFAULT GUID ---
{8bab1a35-2e91-4c93-b9a7-892b5f0884ee}

#### Tool: Bash

**Input:**

```json
{
  "command": "for d in kali-linux archlinux Ubuntu-26.04; do printf '%s\\n' \"--- $d TOOLS ---\"; MSYS_NO_PATHCONV=1 wsl.exe -d \"$d\" -- sh -c 'for x in git ansible ansible-playbook docker podman tailscale ssh python3; do if command -v \"$x\" >/dev/null 2>&1; then printf \"%s: \" \"$x\"; \"$x\" --version 2>&1 | head -n 1; else printf \"%s: absent\\n\" \"$x\"; fi; done' 2>&1; done",
  "description": "Kiểm tra bộ công cụ Linux trong từng distro",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- kali-linux TOOLS ---
: absent
: absent
: absent
: absent
: absent
: absent
: absent
: absent
--- archlinux TOOLS ---
: absent
: absent
: absent
: absent
: absent
: absent
: absent
: absent
--- Ubuntu-26.04 TOOLS ---
: absent
: absent
: absent
: absent
: absent
: absent
: absent
: absent

#### Tool: Bash

**Input:**

```json
{
  "command": "for d in kali-linux archlinux Ubuntu-26.04; do printf '%s\\n' \"--- $d WSL CONF ---\"; MSYS_NO_PATHCONV=1 wsl.exe -d \"$d\" -- sh -c 'if test -f /etc/wsl.conf; then cat /etc/wsl.conf; else echo missing; fi; echo \"--- FAILED ---\"; systemctl --failed --no-legend 2>&1 || true' 2>&1; done",
  "description": "Kiểm tra cấu hình WSL và unit lỗi trong distro",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- kali-linux WSL CONF ---
[boot]
systemd=true
--- FAILED ---
● tpm-udev.path    loaded failed failed Handle dynamically added tpm devices
● tpm-udev.service loaded failed failed Handle dynamically added tpm devices
--- archlinux WSL CONF ---
[boot]
command="sysctl -p /etc/sysctl.d/99-wsl-memory-tuning.conf; mkdir -p /dev/shm/pcn_cache && mount -t tmpfs -o rw,nosuid,nodev,size=2G,mode=0777 tmpfs /dev/shm/pcn_cache"
systemd=true

[automount]
enabled=true
mountFsTab=true
root=/mnt/
options="metadata,umask=22,fmask=11,case=off"

[network]
generateHosts=true
generateResolvConf=true

[interop]
enabled=true
appendWindowsPath=true
--- FAILED ---
--- Ubuntu-26.04 WSL CONF ---
[boot]
systemd=true
--- FAILED ---

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VMWARE TOOL ---\"; Get-Command vmrun.exe -ErrorAction SilentlyContinue | Select-Object Source,Version; Write-Output \"--- SSH ---\"; Get-Service sshd -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -AutoSize; Write-Output \"--- TAILSCALE ---\"; Get-Service Tailscale -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -AutoSize; Write-Output \"--- COMMANDS ---\"; Get-Command git.exe,code.exe,docker.exe,podman.exe,tailscale.exe -ErrorAction SilentlyContinue | Select-Object Name,Source,Version'",
  "description": "Kiểm tra công cụ và dịch vụ Windows hỗ trợ lab",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Exit code 1
--- VMWARE TOOL ---
--- SSH ---

Name  Status StartType
----  ------ ---------
sshd Stopped    Manual


--- TAILSCALE ---

Name       Status StartType
----       ------ ---------
Tailscale Stopped    Manual


--- COMMANDS ---

Name          Source                                   Version 
----          ------                                   ------- 
git.exe       C:\Program Files\Git\mingw64\bin\git.exe 2.53.0.1
tailscale.exe C:\Program Files\Tailscale\tailscale.exe 1.90.9.0

> Tool failed.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Get-Counter \"\\Memory\\Available MBytes\",\"\\Memory\\Committed Bytes\",\"\\Memory\\Commit Limit\" | Select-Object -ExpandProperty CounterSamples | Format-Table Path,CookedValue -AutoSize; Get-Process -Name vmmemWSL -ErrorAction SilentlyContinue | Select-Object ProcessName,WorkingSet64,PrivateMemorySize64,VirtualMemorySize64 | Format-Table -AutoSize'",
  "description": "Đo lại áp lực bộ nhớ sau khảo sát WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

Path                             CookedValue
----                             -----------
\\iphone\memory\available mbytes        4665
\\iphone\memory\committed bytes  46567981056
\\iphone\memory\commit limit     68409155584



ProcessName WorkingSet64 PrivateMemorySize64 VirtualMemorySize64
----------- ------------ ------------------- -------------------
vmmemWSL      2532175872         14189158400         19360841728

#### Thinking

**Fixing shell variable expansion bug****Refining command checks and installation detection**

#### Thinking

**Verifying Ansible installation status**

#### Tool: Bash

**Input:**

```json
{
  "command": "for d in kali-linux archlinux Ubuntu-26.04; do printf '%s\\n' \"--- $d TOOLS ---\"; MSYS_NO_PATHCONV=1 wsl.exe -d \"$d\" -- sh -c 'command -v git || echo git:absent; command -v ansible || echo ansible:absent; command -v ansible-playbook || echo ansible-playbook:absent; command -v docker || echo docker:absent; command -v podman || echo podman:absent; command -v tailscale || echo tailscale:absent; command -v ssh || echo ssh:absent; command -v python3 || echo python3:absent' 2>&1; done",
  "description": "Xác nhận toolchain trong từng distro WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- kali-linux TOOLS ---
/usr/bin/git
ansible:absent
ansible-playbook:absent
docker:absent
podman:absent
tailscale:absent
/usr/bin/ssh
/usr/bin/python3
--- archlinux TOOLS ---
/usr/sbin/git
ansible:absent
ansible-playbook:absent
docker:absent
podman:absent
tailscale:absent
ssh:absent
/usr/sbin/python3
--- Ubuntu-26.04 TOOLS ---
/usr/bin/git
ansible:absent
ansible-playbook:absent
docker:absent
podman:absent
tailscale:absent
/usr/bin/ssh
/usr/bin/python3

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VMWARE DIRS ---\"; Get-ChildItem \"C:\\Program Files (x86)\\VMware\",\"C:\\Program Files\\VMware\" -ErrorAction SilentlyContinue | Select-Object FullName,Name; Write-Output \"--- VMRUN SEARCH ---\"; Get-ChildItem \"C:\\Program Files (x86)\\VMware\",\"C:\\Program Files\\VMware\" -Filter vmrun.exe -Recurse -ErrorAction SilentlyContinue | Select-Object FullName; Write-Output \"--- SERVICES ---\"; Get-Service *VMware* -ErrorAction SilentlyContinue | Format-Table Name,Status,StartType -AutoSize'",
  "description": "Xác minh VMware và vmrun trên Windows",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- VMWARE DIRS ---

FullName                                                   Name              
--------                                                   ----              
C:\Program Files (x86)\VMware\VMware VIX                   VMware VIX        
C:\Program Files (x86)\VMware\VMware Workstation           VMware Workstation
--- VMRUN SEARCH ---
C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe                   
--- SERVICES ---



Name                    Status StartType
----                    ------ ---------
VMware NAT Service     Running Automatic
VmwareAutostartService Stopped    Manual

#### Tool: Bash

**Input:**

```json
{
  "command": "for d in kali-linux archlinux Ubuntu-26.04; do printf '%s\\n' \"--- $d PATH ---\"; MSYS_NO_PATHCONV=1 wsl.exe -d \"$d\" -- sh -c 'printf \"%s\\n\" \"$PATH\"; python3 --version 2>&1 || true; git --version 2>&1 || true; ansible --version 2>&1 || true' 2>&1; done",
  "description": "Kiểm tra PATH và phiên bản toolchain WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- kali-linux PATH ---
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/usr/lib/linux-tools/6.18.54.1-microsoft-standard-WSL2/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Users/Administrator/.qoder/plugins/cache/qoderapp-bundler/qoder-context/1.0.97.fb328997/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/local/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Program Files/Git/cmd:/mnt/c/Program Files/nodejs:/mnt/c/Users/Administrator/AppData/Roaming/npm:/mnt/c/Users/Administrator/AppData/Local/pnpm:/mnt/c/Users/Administrator/scoop/shims:/mnt/c/WINDOWS/System32:/mnt/c/WINDOWS:/mnt/c/Program Files/Common Files/Oracle/Java/javapath:/mnt/c/Program Files/Volta:/mnt/c/Program Files/PowerShell/7:/mnt/c/Python313/Scripts:/mnt/c/Python313:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/java8path:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/javapath:/mnt/c/ProgramData/scoop/shims:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Windows/System32/OpenSSH:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files (x86)/NVIDIA Corporation/PhysX/Common:/mnt/c/Program Files (x86)/wol:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/Program Files/VideoLAN/VLC:/mnt/c/Program Files/Cloudflare/Cloudflare WARP:/mnt/c/Program Files/dotnet:/mnt/c/Program Files/NVIDIA Corporation/NVIDIA app/NvDLISR:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Administrator/.lmstudio/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Ollama:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/rclone:/mnt/c/Program Files/nodejs:/mnt/c/Program Files/Tailscale:/mnt/c/setup/sdk/platform-tools:/mnt/c/Program Files/usbipd-win:/mnt/c/Program Files/PowerToys/DSCModules:/mnt/c/Program Files/PowerShell/7:/mnt/c/Program Files/WSL:/mnt/c/Program Files/Qoder IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314/Scripts:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314:/mnt/c/Users/Administrator/.local/bin:/mnt/c/Users/Administrator/AppData/Local/Volta/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WinGet/Links:/mnt/c/Users/Administrator/AppData/Local/Programs/AIShell:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin/copilot-shim:/mnt/c/Program Files/Git/usr/bin/vendor_perl:/mnt/c/Program Files/Git/usr/bin/core_perl
Python 3.14.6
git version 2.53.0
sh: 1: ansible: not found
--- archlinux PATH ---
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/usr/lib/linux-tools/6.18.54.1-microsoft-standard-WSL2/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Users/Administrator/.qoder/plugins/cache/qoderapp-bundler/qoder-context/1.0.97.fb328997/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/local/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Program Files/Git/cmd:/mnt/c/Program Files/nodejs:/mnt/c/Users/Administrator/AppData/Roaming/npm:/mnt/c/Users/Administrator/AppData/Local/pnpm:/mnt/c/Users/Administrator/scoop/shims:/mnt/c/WINDOWS/System32:/mnt/c/WINDOWS:/mnt/c/Program Files/Common Files/Oracle/Java/javapath:/mnt/c/Program Files/Volta:/mnt/c/Program Files/PowerShell/7:/mnt/c/Python313/Scripts:/mnt/c/Python313:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/java8path:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/javapath:/mnt/c/ProgramData/scoop/shims:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Windows/System32/OpenSSH:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files (x86)/NVIDIA Corporation/PhysX/Common:/mnt/c/Program Files (x86)/wol:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/Program Files/VideoLAN/VLC:/mnt/c/Program Files/Cloudflare/Cloudflare WARP:/mnt/c/Program Files/dotnet:/mnt/c/Program Files/NVIDIA Corporation/NVIDIA app/NvDLISR:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Administrator/.lmstudio/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Ollama:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/rclone:/mnt/c/Program Files/nodejs:/mnt/c/Program Files/Tailscale:/mnt/c/setup/sdk/platform-tools:/mnt/c/Program Files/usbipd-win:/mnt/c/Program Files/PowerToys/DSCModules:/mnt/c/Program Files/PowerShell/7:/mnt/c/Program Files/WSL:/mnt/c/Program Files/Qoder IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314/Scripts:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314:/mnt/c/Users/Administrator/.local/bin:/mnt/c/Users/Administrator/AppData/Local/Volta/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WinGet/Links:/mnt/c/Users/Administrator/AppData/Local/Programs/AIShell:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin/copilot-shim:/mnt/c/Program Files/Git/usr/bin/vendor_perl:/mnt/c/Program Files/Git/usr/bin/core_perl
Python 3.14.8
git version 2.56.0
sh: line 1: ansible: command not found
--- Ubuntu-26.04 PATH ---
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/usr/lib/linux-tools/6.18.54.1-microsoft-standard-WSL2/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Users/Administrator/.qoder/plugins/cache/qoderapp-bundler/qoder-context/1.0.97.fb328997/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/local/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Users/Administrator/bin:/mnt/c/Users/Administrator/.qoder/bin:/mnt/c/Program Files/Git/cmd:/mnt/c/Program Files/nodejs:/mnt/c/Users/Administrator/AppData/Roaming/npm:/mnt/c/Users/Administrator/AppData/Local/pnpm:/mnt/c/Users/Administrator/scoop/shims:/mnt/c/WINDOWS/System32:/mnt/c/WINDOWS:/mnt/c/Program Files/Common Files/Oracle/Java/javapath:/mnt/c/Program Files/Volta:/mnt/c/Program Files/PowerShell/7:/mnt/c/Python313/Scripts:/mnt/c/Python313:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/java8path:/mnt/c/Program Files (x86)/Common Files/Oracle/Java/javapath:/mnt/c/ProgramData/scoop/shims:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Windows/System32/OpenSSH:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/Program Files (x86)/NVIDIA Corporation/PhysX/Common:/mnt/c/Program Files (x86)/wol:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/Program Files/VideoLAN/VLC:/mnt/c/Program Files/Cloudflare/Cloudflare WARP:/mnt/c/Program Files/dotnet:/mnt/c/Program Files/NVIDIA Corporation/NVIDIA app/NvDLISR:/mnt/d/Onedrive/SUGirl/OneDrive - sugirl/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Administrator/.lmstudio/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Ollama:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/rclone:/mnt/c/Program Files/nodejs:/mnt/c/Program Files/Tailscale:/mnt/c/setup/sdk/platform-tools:/mnt/c/Program Files/usbipd-win:/mnt/c/Program Files/PowerToys/DSCModules:/mnt/c/Program Files/PowerShell/7:/mnt/c/Program Files/WSL:/mnt/c/Program Files/Qoder IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314/Scripts:/mnt/c/Users/Administrator/AppData/Local/Programs/Python/Python314:/mnt/c/Users/Administrator/.local/bin:/mnt/c/Users/Administrator/AppData/Local/Volta/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/Users/Administrator/AppData/Local/Microsoft/WinGet/Links:/mnt/c/Users/Administrator/AppData/Local/Programs/AIShell:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Antigravity IDE/bin:/mnt/c/Users/Administrator/AppData/Local/Programs/Microsoft VS Code/bin/copilot-shim:/mnt/c/Program Files/Git/usr/bin/vendor_perl:/mnt/c/Program Files/Git/usr/bin/core_perl
Python 3.14.4
git version 2.53.0
sh: 1: ansible: not found

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- WSL CONFIG FILE ---\"; Get-Item \"C:\\Users\\Administrator\\.wslconfig\" | Select-Object FullName,Length,LastWriteTime; Write-Output \"--- WSL DISK DIR ---\"; Get-ChildItem \"D:\\WSL\" -Directory | Select-Object Name,LastWriteTime; Write-Output \"--- PROJECT FS ---\"; Get-Item \"D:\\Lab\" | Select-Object FullName,Attributes,CreationTime,LastWriteTime'",
  "description": "Xác nhận vị trí các vùng dữ liệu WSL và dự án",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- WSL CONFIG FILE ---

FullName                          Length LastWriteTime        
--------                          ------ -------------        
C:\Users\Administrator\.wslconfig   1260 11/2/2026 9:25:42 AM 
--- WSL DISK DIR ---
                                         10/29/2026 2:28:30 PM
                                         10/29/2026 2:53:14 PM
                                         10/29/2026 2:53:48 PM
--- PROJECT FS ---
D:\Lab                                   11/7/2026 10:04:22 AM

#### Thinking

**Planning final verification and linking****Summarizing WSL memory and distro status**

#### Thinking

**Verifying VMware vmnet and WSL network interfaces****Summarizing network adapters and WSL storage details**

#### Thinking

**Assessing memory constraints for WSL and VMware****Clarifying WSL memory scenarios and control plane setup****Identifying WSL limitations for multi-segment capture**

#### Thinking

**Assessing nested virtualization and networking limits in WSL****Verifying nested virtualization and network adapters in WSL**

Khảo sát đủ để đưa ra khuyến nghị sơ bộ: WSL nên là control plane/tooling, không nên gánh 12 VM và các segment L2. Mình kiểm tra thêm hai điểm quyết định cuối: các vmnet thực tế đang có trên Windows và WSL có thiết bị ảo hóa/L2 cần cho lab hay không.

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- VMNET IPS ---\"; Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -like \"VMware Network Adapter*\" | Format-Table InterfaceAlias,IPAddress,PrefixLength,AddressState -AutoSize; Write-Output \"--- ALL VMNET ADAPTERS ---\"; Get-NetAdapter -Name \"VMware Network Adapter*\" -ErrorAction SilentlyContinue | Format-Table Name,Status,MacAddress,LinkSpeed -AutoSize'",
  "description": "Kiểm tra các vmnet thực tế trên Windows",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- VMNET IPS ---

InterfaceAlias                IPAddress    PrefixLength AddressState
--------------                ---------    ------------ ------------
VMware Network Adapter VMnet8 192.168.30.1           24    Preferred
VMware Network Adapter VMnet1 192.168.42.1           24    Preferred


--- ALL VMNET ADAPTERS ---

Name                          Status MacAddress        LinkSpeed
----                          ------ ----------        ---------
VMware Network Adapter VMnet1 Up     00-50-56-C0-00-01 100 Mbps 
VMware Network Adapter VMnet8 Up     00-50-56-C0-00-08 100 Mbps

#### Tool: Bash

**Input:**

```json
{
  "command": "MSYS_NO_PATHCONV=1 wsl.exe -d archlinux -- sh -c 'echo \"--- DEVICES ---\"; ls -l /dev/dxg /dev/kvm /dev/net/tun 2>&1 || true; echo \"--- LINKS ---\"; ip -brief link; echo \"--- CAPABILITIES ---\"; grep Cap /proc/self/status'",
  "description": "Kiểm tra thiết bị ảo hóa và network interface WSL",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- DEVICES ---
crw-rw-rw- 1 root root 10, 258 Nov  7 10:23 /dev/dxg
crw-rw---- 1 root kmem 10, 232 Nov  7 10:23 /dev/kvm
crw-rw-rw- 1 root root 10, 200 Nov  7 10:23 /dev/net/tun
--- LINKS ---
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
eth0             UP             00:15:5d:7d:37:9e <BROADCAST,MULTICAST,UP,LOWER_UP> 
--- CAPABILITIES ---
CapInh:	0000000000000000
CapPrm:	000001ffffffffff
CapEff:	000001ffffffffff
CapBnd:	000001ffffffffff
CapAmb:	0000000000000000

#### Tool: Bash

**Input:**

```json
{
  "command": "powershell.exe -NoProfile -Command 'Write-Output \"--- MEMORY BY PROCESS ---\"; Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 12 ProcessName,Id,@{Name=\"WorkingSetGB\";Expression={[math]::Round($_.WorkingSet64/1GB,2)}},@{Name=\"PrivateGB\";Expression={[math]::Round($_.PrivateMemorySize64/1GB,2)}} | Format-Table -AutoSize'",
  "description": "Xác định tiến trình đang chiếm bộ nhớ host",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

--- MEMORY BY PROCESS ---

ProcessName           Id WorkingSetGB PrivateGB
-----------           -- ------------ ---------
Memory Compression  4084         7.02      0.02
vmmemWSL           12832         2.34     13.18
Notepad            32504         0.91       0.9
msedge             17448         0.79      0.74
msedge             25196          0.5      0.52
msedge             27404         0.48       0.5
comet              26272         0.45      0.39
dwm                 2056         0.43      0.61
comet              30808         0.36      0.29
Qoder              25288         0.34      0.41
msedge              8024         0.34      0.46
Taskmgr            20052         0.34      0.16

#### Thinking

**Assessing WSL storage and prompt injection risks****Surveying WSL memory, virtualization, and network capabilities****Planning WSL to VMware network connectivity test**

#### Thinking

**Testing WSL connectivity to Windows VMnet IPs****Confirming missing VMware VMnets and planning report**

#### Thinking

**Enforcing absolute-path linking for local files****Planning absolute-path linking with line citations**

Khảo sát đã đủ dữ liệu để kết luận, không cần cài thêm gì hay thay đổi cấu hình. Mình sẽ chốt trạng thái các hạng mục rồi gửi bạn bản đánh giá gồm hiện trạng, giới hạn, và phương án WSL hợp lý nhất cho lab này.

#### Thinking

**Resolving race condition with sequential task updates**

#### Thinking

**Planning absolute-path Markdown linking for local files****Documenting WSL2 and system details with source links**

#### Thinking

**Assessing system memory and network configuration****Evaluating WSL control-plane feasibility and limitations**

#### Thinking

**Assessing storage strategy for WSL performance****Planning WSL and VM resource allocation****Recommending separate WSL operational modes**

#### Thinking

**Confirming service separation constraints****Outlining WSL and Windows service roles****Comparing two-host versus hybrid designs**

#### Thinking

**Recommending environments and referencing files****Clarifying file references and proposing environment options**

Kết luận khảo sát: môi trường đủ tốt để làm control plane, nhưng chưa phù hợp để dồn toàn bộ lab vào WSL; hơn nữa các tool chính như Ansible chưa được cài và SSH/Tailscale Windows đang dừng. Mình đã không thay đổi cấu hình hay cài đặt nào.

#### Thinking

**Summarizing system specs and project evidence****Detailing WSL config and VM network discrepancies**

#### Thinking

**Confirming available and missing tools****Evaluating VMware and WSL storage setup**

#### Thinking

**Assessing WSL storage and performance setup****Evaluating WSL resource and network limitations****Recommending WSL resource allocation adjustments**

#### Thinking

**Assessing memory allocation constraints****Recommending lab host optimization and distro consolidation****Considering Ubuntu for control plane base**

#### Thinking

**Confirming environment matches Hùng machine****Assessing WSL limitations and next steps****Drafting user option recommendations**

**Kết quả khảo sát**

- Máy hiện tại là Windows 11 Pro, 32 GB RAM, i5-12500H/16 luồng, RTX 3050 4 GB.
- Có 3 distro WSL2: Kali, Arch và Ubuntu 26.04; distro mặc định là Arch.
- Các distro nằm ở `D:\WSL`; Arch dùng khoảng 64 GiB VHDX. Ổ `D:` là HDD 1 TB, còn khoảng 327 GB; ổ `C:` là NVMe 512 GB, còn khoảng 89 GB.
- [`.wslconfig`](file:///C:/Users/Administrator/.wslconfig#L8) đang cấp `14 GB RAM`, `10 vCPU`, `16 GB swap`, bật nested virtualization, NAT và GPU GUI.
- WSL đã nhìn thấy GPU NVIDIA qua `/dev/dxg` và `nvidia-smi`; tuy nhiên lab này không có workload GPU.
- Hiện `vmmemWSL` dùng khoảng 13–14 GB private memory; Windows chỉ còn khoảng 4.5 GB RAM khả dụng và đang dùng memory compression khá mạnh.

**Đối chiếu với dự án**

Tài liệu [ha-lb-security-lab.html:79](file:///D:/Lab/ha-lb-security-lab.html#L79) mô tả đúng kiểu máy này: 32 GB RAM, VMware chạy toàn bộ lab, còn WSL ở vai trò control plane. Dự án dự kiến cần khoảng 17 GB cho 12 VM khi bật đầy đủ tại [ha-lb-security-lab.html:85](file:///D:/Lab/ha-lb-security-lab.html#L85).

Hiện tại:

- `D:\Lab` chỉ có tài liệu thiết kế, chưa có repository triển khai, inventory, playbook hay Compose.
- VMware đã cài và có `vmrun.exe`, nhưng chỉ đang có VMnet1 và VMnet8; thiết kế cần 6 vmnet riêng tại [ha-lb-security-lab.html:95](file:///D:/Lab/ha-lb-security-lab.html#L95).
- Chưa có Ansible, Docker, Podman hoặc Tailscale trong các distro WSL.
- Git và Python đã có; SSH client có trong Kali/Ubuntu.
- Windows OpenSSH và Tailscale hiện đang dừng.
- Arch systemd đang chạy; Kali bị `degraded` do `tpm-udev`; Ubuntu còn trạng thái `starting` và báo lỗi systemd user session.

**Kết luận kiến trúc**

Không nên đưa toàn bộ lab vào WSL. Với dự án này, WSL không có lợi thế để thay thế VMware vì:

- OPNsense/CARP/pfsync cần topology L2 và nhiều vNIC.
- Keepalived/VRRP cần multicast giữa các segment.
- Suricata, Zeek và sensor cần capture/promiscuous traffic.
- Thiết kế yêu cầu 6 vmnet; WSL hiện chỉ có một `eth0` trong mạng NAT.
- Nếu chạy cả 12 VM trong WSL thông qua nested virtualization, bộ nhớ sẽ bị cạnh tranh:

```text
VMware lab       ~17 GB
WSL hiện tại     ~14 GB
Windows host     cần ít nhất 8-10 GB
Tổng             vượt xa 32 GB
```

**Mô hình nên dùng**

1. **WSL:** Git, Ansible, policy-as-code, validator, script kiểm thử, SSH config.
2. **Windows:** VMware Workstation, `vmrun`, OpenSSH Server, Tailscale, các vmnet.
3. **VMware:** OPNsense, HAProxy, web, PostgreSQL, Suricata, Zeek, observability.
4. **Kết nối:** WSL gọi `vmrun` trên Windows và dùng ProxyJump qua Windows host vào từng VM, đúng hướng đã mô tả tại [ha-lb-security-lab.html:117](file:///D:/Lab/ha-lb-security-lab.html#L117).

**Điều chỉnh tài nguyên nên hướng tới**

Không nên để WSL giữ mức 14 GB cho vai trò control plane. Mức hợp lý hơn:

- WSL hard cap: khoảng 3–4 GB.
- WSL CPU: 4–6 vCPU.
- Swap: 4–8 GB.
- VMware: khoảng 13.5 GB ở steady state; bật attacker/sensor khi cần như thiết kế tại [ha-lb-security-lab.html:197](file:///D:/Lab/ha-lb-security-lab.html#L197).
- Không chạy Docker/VM/nested hypervisor trong WSL nếu không có workload cụ thể cần nó.

Cũng không nên đặt repository có nhiều file nhỏ, cache hoặc `node_modules` trên `/mnt/d`; nếu sau này có code thật, đặt phần làm việc chính trong filesystem Linux của WSL. Tuy nhiên filesystem WSL hiện cũng nằm trên HDD `D:`, nên workload I/O nặng vẫn sẽ chậm. Chưa cần chuyển sang NVMe vì hiện dự án mới chỉ có tài liệu và ổ `C:` không còn dư quá nhiều.

**Khuyến nghị**

Giữ WSL như một **control plane nhẹ**, không phải “máy chủ chứa toàn bộ lab”. Cách lười nhưng đúng ở đây là:

> Bỏ nested VM, container và database trong WSL; chỉ thêm chúng khi một workload cụ thể chứng minh rằng VMware không đáp ứng.

Bước tiếp theo hợp lý là tạo một profile control-plane tối thiểu trong **một** distro WSL: Ansible + Git + SSH, sau đó kiểm tra ba đường đi `WSL → Windows SSH`, `WSL → vmrun`, và `WSL → ProxyJump → một VM`. Chưa nên cài hoặc chỉnh gì cho đến khi bạn đồng ý với mô hình này.

[hook: Stop] succeeded (exit 0)

[hook: Stop] succeeded (exit 0)

### **You**

lập cho tôi kế hoạch triển khai dự án này, step by step càng tốt, và nói rõ phần nào bạn làm thay tôi được, phần nào không để tôi tự làm và hướng dẫn tôi phần tôi tự làm

### **Assistant**

[hook: UserPromptSubmit] succeeded (exit 0)

#### Thinking

**Planning deployment project steps****Deciding skill invocation for detailed planning****Preparing to invoke writing-plans skill**

Mình sẽ chuyển khảo sát thành kế hoạch triển khai theo từng phase, tách rõ việc có thể tự động hóa khỏi việc cần bạn thao tác trên Windows/VMware hoặc xác nhận an toàn. Trước hết mình sẽ nạp quy trình lập kế hoạch và rà lại tài liệu thiết kế để kế hoạch bám đúng topology 12 VM, 6 vmnet và các tiêu chí kiểm thử.

#### Tool: Skill

**Input:**

```json
{
  "skill": "superpowers:writing-plans",
  "args": "Lập kế hoạch triển khai step-by-step cho lab HA/load-balancer/security được mô tả trong D:\\Lab\\ha-lb-security-lab.html. Kế hoạch cần bằng tiếng Việt, phân chia rõ: assistant có thể làm trong workspace, user phải thao tác/cho phép trên Windows/VMware/WSL, và hướng dẫn user cho phần đó. Chưa triển khai hay sửa code; chỉ lập kế hoạch."
}
```

**Response:**

Launching skill: superpowers:writing-plans

#### Thinking

**Planning architectural documentation****Preparing multi-step plan in Vietnamese****Verifying plan document path existence**

#### Thinking

**Outlining phased implementation plan****Expanding detailed phased plan with file structure**

#### Thinking

**Clarifying operational limitations and permissions****Planning to create design plan document****Planning targeted HTML section reads**

Mình đang dùng writing-plans để tạo kế hoạch triển khai. Vì đây là lab nhiều subsystem, mình sẽ giữ một kế hoạch tổng thể nhưng chia thành các phase có checkpoint; mỗi phase sẽ ghi rõ người thực hiện, đầu vào, lệnh kiểm tra và điều kiện dừng.

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 1,
  "limit": 70,
  "pages": ""
}
```

**Response:**

1	<!DOCTYPE html>
2	<html lang="vi">
3	<head>
4	<meta charset="UTF-8">
5	<title>Đề tài Lab v4.2 — Firewall &amp; Security-First, 2 tuần, 1 máy host + Tailscale</title>
6	<style>
7	    body { font-family: "Times New Roman", Arial, sans-serif; line-height: 1.6; margin: 40px; color: #111; max-width: 1140px; }
8	    h1 { text-align: center; font-size: 22px; text-transform: uppercase; }
9	    h2 { font-size: 18px; margin-top: 30px; border-bottom: 2px solid #333; padding-bottom: 4px; }
10	    h3 { font-size: 16px; margin-top: 20px; }
11	    table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 14px; }
12	    th, td { border: 1px solid #000; padding: 7px 8px; text-align: left; vertical-align: top; }
13	    th { background-color: #f2f2f2; }
14	    pre { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; overflow-x: auto; font-family: Consolas, monospace; font-size: 12.5px; }
15	    code { background: #eee; padding: 1px 4px; font-family: Consolas, monospace; font-size: 12.5px; }
16	    .center { text-align: center; }
17	    .b45 { background: #8b1a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
18	    .b4  { background: #b4531a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
19	    .b3  { background: #7a6a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
20	    .note { background: #fff8e1; border-left: 4px solid #d4a017; padding: 10px 14px; margin: 12px 0; }
21	    .kpi { background: #eef4fb; border-left: 4px solid #2b5f8a; padding: 10px 14px; margin: 12px 0; }
22	    .stop { background: #fdecec; border-left: 4px solid #a33; padding: 10px 14px; margin: 12px 0; }
23	    .ok { background: #eaf5ea; border-left: 4px solid #2a7; padding: 10px 14px; margin: 12px 0; }
24	    ul, ol { margin-top: 6px; } li { margin-bottom: 4px; }
25	</style>
26	</head>
27	<body>
28	<h1>ĐỀ TÀI LAB v4.2 — FIREWALL &amp; SECURITY-FIRST</h1>
29	<p class="center"><strong>
30	Perimeter nhiều vùng có HA thật, IPS inline, chính sách dạng mã nguồn,
31	dịch vụ được bảo vệ nhiều lớp — vận hành trên một máy host, điều khiển từ máy thứ hai qua Tailscale
32	</strong></p>
33	
34	<div class="kpi">
35	<strong>v4.2 = 115.5 giờ, 12 VM (tất cả trên máy Hùng), Hùng 60h / Bảo 55.5h, lịch 14 ngày, chi phí phần cứng 0 đồng.</strong>
36	115.5h = <strong>82%</strong> quỹ 140 giờ (2 người × 10 ngày × 7 giờ) → còn 24.5 giờ đệm.
37	Độ khó trung bình <strong>≈ 4.35/5</strong>, cụm tường lửa–an ninh đạt <strong>4.5–4.8</strong>.
38	<br><br>
39	<strong>Thay đổi so với v4.1:</strong> bỏ toàn bộ dây cáp và USB-Ethernet adapter. Hai laptop nối nhau qua
40	<strong>Tailscale</strong>; máy Bảo làm việc từ xa bằng <code>ProxyJump</code> + port-forward —
41	<em>không</em> advertise route, <em>không</em> bật IP forwarding trên Windows. Được: GĐ0 giảm 12h xuống 8.5h,
42	toàn bộ lớp lỗi ghép nối giữa 2 máy biến mất, đường quản trị không còn chạm vào chính sách perimeter.
43	Mất: <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> nằm trong máy Hùng nên
44	attack validation giảm 4.6 xuống 4.2, NFR-13 chỉ còn đúng theo nghĩa phân tách vùng, và tiến độ của Bảo
45	phụ thuộc việc máy Hùng có bật hay không.
46	<br><br>
47	<strong>Bảy điều bắt buộc lưu ý khi dùng Tailscale nằm ở mục 2.4.</strong> Hai điều dễ chết người nhất:
48	mặc định Tailscale <em>hết hạn key sau 180 ngày</em>, và đừng cố <code>--advertise-routes</code> + IP forwarding trên Windows.
49	<br><br>
50	So với v3: chiều sâu dịch vụ bị giảm có chủ đích (bỏ drain/reload 0 lỗi, bỏ Redis session, bỏ rolling deploy,
51	bỏ auto-failover DB phức tạp) để dồn ngân sách vào 4 thứ: <em>perimeter HA, IPS inline, policy-as-code, kiểm chứng tấn công</em>.
52	</div>
53	
54	<h2>1. Thay đổi so với v3</h2>
55	<table>
56	    <tr><th>Chủ đề</th><th>v3</th><th>v4</th><th>Lý do</th></tr>
57	    <tr><td>Thiết bị biên</td><td>1× Debian + nftables</td><td><strong>2× OPNsense, CARP + pfsync + cfgsync</strong>, 5 vùng</td>
58	        <td>Đánh mạnh tường lửa thì phải có thiết bị biên thật, có HA, có state sync</td></tr>
59	    <tr><td>IPS</td><td>Suricata pcap / alert</td><td><strong>Suricata inline NFQUEUE (blocking)</strong> + test fail-open</td>
60	        <td>Chặn thật ở perimeter, không chỉ phát hiện</td></tr>
61	    <tr><td>Chính sách</td><td>File nftables trong Git</td><td><strong>YAML khai báo → render qua API OPNsense → apply không gián đoạn</strong></td>
62	        <td>Điểm khó nhất và cũng là điểm ăn tiền nhất của phần firewall</td></tr>
63	    <tr><td>Rate limit</td><td>Ở HAProxy (stick-table)</td><td><strong>Dịch chuyển xuống firewall</strong> (max states / alias + policy)</td>
64	        <td>Đúng chủ đề hơn: chống flood là việc của perimeter</td></tr>
65	    <tr><td>Góc nhìn tấn công</td><td>Client trong cùng host</td><td><strong>Attacker + sensor trên vmnet WAN riêng</strong> (v4.2: không còn ở máy thứ 2)</td>
66	        <td>Firewall chỉ có ý nghĩa khi bị đánh từ ngoài; sensor cho bằng chứng độc lập</td></tr>
67	    <tr><td>Hypervisor</td><td>VirtualBox + unicast hack</td><td><strong>VMware Workstation Pro</strong> (miễn phí cá nhân)</td>
68	        <td>CARP/pfsync dùng multicast — vmnet của VMware xử lý được, VirtualBox thì không ổn định</td></tr>
69	    <tr><td>HAProxy</td><td>8 tính năng, 15.5h</td><td>4 tính năng, 7h (TLS, mTLS, healthcheck, VIP)</td>
70	        <td>Nhượng giờ cho firewall</td></tr>

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 330,
  "limit": 220,
  "pages": ""
}
```

**Response:**

330	<h3>Cụm F — Bằng chứng, quan sát, tự động hoá (Bảo)</h3>
331	<ul>
332	    <li>Remote syslog 3 nguồn từ OPNsense + web + db → obs (rsyslog → Loki); 3 dashboard Grafana với 4 panel chính: policy hit, IPS block, WAF block, state table.</li>
333	    <li><strong>Mặt phẳng giám sát nằm ngoài vùng bảo vệ</strong> (NFR-13): <code>obs</code>, <code>ca</code>, <code>sensor</code> nằm ở vùng MGMT/WAN riêng,
334	        nên không node nào trong vùng bị bảo vệ có khả năng xoá hoặc sửa bằng chứng về chính nó. Kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert.</li>
335	    <li>Prometheus: node_exporter, haproxy export, postgres_exporter; 6 alert: mất master CARP, IPS xuống, rule counter bất thường, 5xx &gt; 1%, DB leader đổi, PITR backup &gt; 24h chưa chạy.</li>
336	    <li>Ansible + <code>make check</code> (lint + <code>haproxy -c</code> + <code>apachectl configtest</code> + <code>suricata -T</code> + gitleaks) + <code>make drift</code>.</li>
337	    <li><code>run_matrix.sh</code> sinh CSV theo schema: <code>scenario,ts,host,detect_s,rto_s,req_total,err_5xx,err_conn,pass</code>.</li>
338	</ul>
339	
340	<h2>7. Cấu hình tham chiếu</h2>
341	
342	<h3>7.1 Mô hình chính sách khai báo (file nguồn duy nhất)</h3>
343	<pre>
344	# policy/zones.yml
345	zones:
346	  wan:       { net: 10.0.0.0/24,        iface: wan }
347	  dmz_front: { net: 192.168.20.0/24,    iface: opt1 }
348	  dmz_app:   { net: 192.168.21.0/24,    iface: opt2 }
349	  trusted:   { net: 192.168.30.0/24,    iface: opt3 }
350	  mgmt:      { net: 192.168.99.0/24,    iface: opt4 }
351	
352	aliases:
353	  LB_VIP:    { type: host,   items: [192.168.20.100] }
354	  APP_NODES: { type: network, items: [192.168.21.21/32, 192.168.21.22/32] }
355	  DB_VIP:    { type: host,   items: [192.168.30.100] }
356	  MGMT_ONLY: { type: network, items: [192.168.99.0/24] }
357	
358	rules:
359	  - id: POL-001
360	    desc: "Public HTTPS vào LB VIP"
361	    zone: wan -> dmz_front
362	    proto: tcp, dst: LB_VIP, dport: 443
363	    action: pass, log: true, test: T-07
364	    nat: { type: static-port-forward, to: 192.168.20.100:443 }
365	
366	  - id: POL-002
367	    desc: "Web truy cập DB, chỉ từ alias APP_NODES"
368	    zone: dmz_app -> trusted
369	    proto: tcp, src: APP_NODES, dst: DB_VIP, dport: 5432
370	    action: pass, log: true, test: T-07
371	
372	  - id: POL-003
373	    desc: "Cấm WAN vào DB (kiểm chứng deny)"
374	    zone: wan -> trusted
375	    proto: any, dst: any, dport: [5432, 3306]
376	    action: block, log: true, test: T-07
377	
378	  - id: POL-004
379	    desc: "Cấm egress từ DMZ-APP và TRUSTED ra WAN"
380	    zone: [dmz_app, trusted] -> wan
381	    proto: any, action: block, log: true, test: T-13
382	
383	  - id: POL-005
384	    desc: "SSH chỉ từ MGMT"
385	    zone: any -> any, proto: tcp, dport: 22
386	    src: MGMT_ONLY, action: pass, log: true
387	    else: { action: reject, test: T-11 }
388	    options: { max-src-conn: 10, max-src-conn-rate: "20/5", overload: { table: "ban_table", clear: 3600 } }
389	</pre>
390	
391	<h3>7.2 Renderer + apply không gián đoạn (Ansible)</h3>
392	<pre>
393	# roles/opnsense_policy/tasks/main.yml  (ý đồ, không phải code chạy ngay)
394	- name: Đồng bộ alias
395	  uri:
396	    url: "https://{{ opns_host }}/api/firewall/alias/{{ item.action }}{{ item.uuid or '' }}"
397	    method: POST
398	    user: "{{ api_key }}"; password: "{{ api_secret }}"
399	    body_format: json
400	    body: { alias: { name: "{{ item.name }}", type: "{{ item.type }}", content: "{{ item.items | join(' ') }}", descr: "{{ item.id }}" } }
401	  loop: "{{ alias_diff }}"
402	
403	- name: Đồng bộ rule (thêm/sửa theo POLICY-ID)
404	  uri:
405	    url: "https://{{ opns_host }}/api/firewall/rule_filter/{{ item.action }}{{ item.uuid or '' }}"
406	    ...
407	- name: Apply — reload filter, KHÔNG cắt state đang có
408	  uri: { url: "https://{{ opns_host }}/api/firewall/rule_filter/apply", method: post, ... }
409	- name: Kích hoạt thay đổi
410	  uri: { url: "https://{{ opns_host }}/api/firewall/filter/apply",   method: post, ... }
411	- name: Cờ an toàn cho NFR-02
412	  debug: { msg: "session trước/sau: {{ st_before }} -> {{ st_after }}" }
413	</pre>
414	<div class="note">
415	<strong>Trước khi viết renderer, làm việc này trong 30 phút:</strong> bật API trên OPNsense (System → Access → Users,
416	tạo user quyền <code>Admin: API</code>), rồi thử <code>GET /api/firewall/alias/searchAlias</code> bằng <code>curl</code> với
417	key/secret. Tên endpoint khác nhau theo phiên bản — xác nhận bằng <code>/api</code> docs trên chính thiết bị của bạn
418	rồi mới viết playbook. Đây là chỗ dễ mất 4 giờ vô ích nhất của cả dự án.
419	</div>
420	
421	<h3>7.3 CARP + pfsync + cfgsync (trên thiết bị)</h3>
422	<pre>
423	# Interface → Assignments: 5 OPT/WAN NIC, đặt descr = tên zone trong YAML
424	# System → Advanced → Networking:
425	#   Disable CARP preempt = ON (tránh flap khi master hồi)
426	#   Allow CARP shared advertisements = ON (2 con cùng host, cùng vmnet)
427	# Virtual IPs: CARP, vhid 1..5 theo zone, advskew 0 (master) / 100 (backup)
428	# System → High Availability:
429	#   Sync items: States, Rules, NAT, Aliases, Static routes
430	#   pfsync interface = vmnet_sync (KHÔNG dùng WAN)
431	#   Remote: 10.0.0.2  |  Sync user: quyền tối thiểu, key chung
432	# Trạng thái phải thấy: "This host is MASTER for vip 1/xxx" và pfsync có packet
433	sysctl net.inet.carp.preempt ; ifconfig carp ; tcpdump -i vmnet_sync -nn proto 24
434	</pre>
435	
436	<h3>7.4 Suricata inline + test fail-closed</h3>
437	<pre>
438	# Services → Intrusion Detection → Administration: Mode = IPS (NFQUEUE), interface = WAN, OPT1, OPT2
439	# Rules: enabled = emerging-ci, policy, trojan; test-local.rules viết tay cho hành vi lab
440	# Test fail-closed:
441	systemctl stop suricata            # hoặc tắt service trong plugin
442	nc -vz 10.0.0.100 443              # kỳ vọng: KHÔNG thông (fail-closed) hoặc thông + alert (fail-open)
443	                                   # → ghi lại lựa chọn và lý do vào báo cáo
444	</pre>
445	
446	<h3>7.5 HAProxy + Keepalived (đã giản lược)</h3>
447	<pre>
448	frontend in_https
449	    bind :443 ssl crt /local/domain/opnsense/haproxy/certs/lab.pem alpn h2,http/1.1
450	    http-request set-header X-Request-ID %[req.uuid]
451	    default_backend be_app
452	backend be_app
453	    option httpchk GET /healthz
454	    http-check expect status 200
455	    default-server inter 2s fastinter 1s fall 3 rise 2
456	    server web1 192.168.21.21:8443 check ssl verify required ca-file /certs/ca.crt client-cert /certs/lb-cli.pem
457	    server web2 192.168.21.22:8443 check ssl verify required ca-file /certs/ca.crt client-cert /certs/lb-cli.pem
458	</pre>
459	<pre>
460	vrrp_instance VI_LB {
461	    state MASTER            # node kia BACKUP + advskew 100
462	    interface eth1
463	    virtual_router_id 51
464	    priority 150
465	    advert_int 1            # multicast: VMware xử lý được, không cần unicast_peer
466	    virtual_ipaddress { 192.168.20.100/24 }
467	    track_script { chk_haproxy }
468	}
469	</pre>
470	
471	<h3>7.6 DB promote + fencing + PITR</h3>
472	<pre>
473	# /usr/local/bin/promote.sh — chạy khi primary chết (cron/watchdog đơn giản, không repmgrd)
474	repmgr standby promote -f /etc/repmgr/16/repmgr.conf
475	ip addr add 192.168.30.100/24 dev eth0 && arping -c3 -A -I eth0 192.168.30.100
476	ansible-playbook -i inv pb/refresh_alias.yml -e "db_vip_node=pg2"   # cập nhật alias firewall nếu cần
477	# fence node cũ:
478	ssh pg1 "systemctl stop postgresql@16-main; repmgr node set --name=pg1 --status=stopped"
479	# PITR:
480	pgbackrest --stanza=pglab --delta --type=time --target="2026-11-18 09:40:00+07" restore
481	</pre>
482	
483	<h2>8. Ma trận kiểm thử — 14 kịch bản</h2>
484	<table>
485	    <tr><th>Mã</th><th>Kịch bản</th><th>Thực hiện từ</th><th>PASS</th></tr>
486	    <tr><td>T-01</td><td>Phân phối tải qua VIP</td><td>attacker</td><td>30 req/s, cả 2 web ≥ 40% request</td></tr>
487	    <tr><td>T-02</td><td>Chết 1 web node</td><td>máy Hùng</td><td>Phát hiện ≤ 6 s, 0 lỗi 5xx, phiên (DB) còn</td></tr>
488	    <tr><td>T-03</td><td>Keepalived VIP đổi chủ</td><td>máy Hùng</td><td>≤ 10 s, mất ≤ 0.5% request đang truyền</td></tr>
489	    <tr><td>T-04</td><td><strong>CARP failover giữ session</strong></td><td>attacker</td><td>iperf3 + ssh đang chạy <em>không đứt</em>, đổi master ≤ 5 s</td></tr>
490	    <tr><td>T-05</td><td>Cắt đường pfsync/heartbeat</td><td>máy Hùng</td><td>Không có 2 MASTER; hành vi được giải thích + có alert</td></tr>
491	    <tr><td>T-06</td><td>cfgsync drift</td><td>cả hai</td><td>Sửa tay trên backup → master không bị ghi đè im lặng; <code>make drift</code> báo đúng</td></tr>
492	    <tr><td>T-07</td><td><strong>Ma trận chính sách 24 combo</strong></td><td>attacker/sensor/web/db</td><td>Khớp YAML 100%; mỗi rule có counter &gt; 0; WAN→DB và SSH phải bị chặn</td></tr>
493	    <tr><td>T-08</td><td><strong>Áp dụng policy dưới tải</strong></td><td>attacker</td><td>Thêm rule + reload: 0 gián đoạn, 0 lỗi 5xx, state giữ nguyên</td></tr>
494	    <tr><td>T-09</td><td>IPS chặn scan + payload</td><td>attacker</td><td>nmap bị phát hiện; ≥ 90% payload bị chặn ở IPS hoặc WAF</td></tr>
495	    <tr><td>T-10</td><td><strong>IPS fail-closed</strong></td><td>attacker</td><td>Suricata chết → hệ thống xử lý đúng lựa chọn đã công bố, có alert</td></tr>
496	    <tr><td>T-11</td><td>SSH brute force</td><td>attacker</td><td>Fail2Ban/overload table ban trong ≤ 5', unban đúng hạn, có log</td></tr>
497	    <tr><td>T-12</td><td>WAF false positive</td><td>attacker</td><td>15 request hợp lệ có nháy/JSON/unicode → 0 block sai</td></tr>
498	    <tr><td>T-13</td><td>DB failover + RPO + PITR</td><td>máy Hùng</td><td>Leader mới ≤ 40 s, commit cuối còn, restore tới timestamp verify 3 bản ghi</td></tr>
499	    <tr><td>T-14</td><td>Cấm egress / chống flood</td><td>web, attacker</td><td>Reverse shell từ web ra WAN thất bại; SYN flood 50k pkt/s không sập VIP</td></tr>
500	</table>
501	
502	<h2>9. PHÂN CÔNG CHI TIẾT THEO 7 GIAI ĐOẠN — 115.5 giờ</h2>
503	<p>
504	Mỗi giai đoạn có <strong>mốc ghép</strong> (hai người cùng xác nhận) và <strong>điều kiện ra</strong>.
505	Mã việc: <code>H##</code> = Hùng, <code>B##</code> = Bảo. Thứ tự đã sắp xếp để không ai phải chờ ai quá một ngày.
506	</p>
507	
508	<h3>GĐ0 — Hạ tầng + Tailscale control plane (ngày 1–2) · 8.5h</h3>
509	<table>
510	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
511	    <tr><td>H01</td><td><strong>Hùng</strong></td>
512	        <td>VMware Workstation Pro. Tạo 12 VM (opns1/2, lb1/2, web1/2, pg1/2, obs, ca, attacker, sensor) từ linked clone
513	        template Debian 12 + OPNsense. Dựng 6 vmnet theo mục 2.1 — <strong>tất cả private, không cấu hình bridged nào</strong>.
514	        Thêm <code>vmnet-sync</code> host-only giữa 2 con opns. Snapshot <code>clean</code>, chrony một source.</td>
515	        <td>3.5</td><td>Mỗi VM đúng số NIC theo mục 3; <code>vmrun list</code> thấy 12; <code>date</code> khớp nhau</td></tr>
516	    <tr><td>B01</td><td><strong>Bảo</strong></td>
517	        <td>Cài Tailscale cả hai máy, cùng tailnet, <code>tailscale set --expiry=0</code> (mục 2.4 #1).
518	        Trên máy Hùng: cài + bật <code>sshd</code> (StartupType Automatic, key-only).
519	        Kiểm từ máy Bảo: <code>ssh hung@100.64.x</code>, rồi <code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào 1 VM bất kỳ.
520	        Ghi IP tailscale của nhau vào <code>docs/interfaces.md</code>.</td>
521	        <td>1.5</td><td>ProxyJump vào được VM — <strong>đây là điều kiện sống còn của cả phương án</strong></td></tr>
522	    <tr><td>B02</td><td><strong>Bảo</strong></td>
523	        <td>Cấu hình <code>attacker</code> (nmap, hping3, hydra, curl, hey, bộ payload) và <code>sensor</code>
524	        (tcpdump, Zeek, rsyslog forward, promiscuous mode trên NIC vmnet-wan) — hai VM này nằm trên máy Hùng nhưng
525	        do Bảo sở hữu và vận hành.</td>
526	        <td>2</td><td>attacker ping 10.0.0.1; sensor bắt được traffic giữa attacker và CARP VIP</td></tr>
527	    <tr><td>B03</td><td><strong>Bảo</strong></td>
528	        <td>Repo Git + <code>.gitignore</code> (<code>*.key</code>, <code>certs/issued/</code>, <code>secrets.yml</code>) + gitleaks.
529	        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
530	        key SSH distribution cho 12 VM, inventory 6 nhóm vùng.</td>
531	        <td>1.5</td><td><code>ansible all -m ping</code> xanh đủ 12 VM; <code>make check</code> chạy được</td></tr>
532	    <tr><td colspan="5"><strong>Mốc ghép:</strong> hai người cùng chạy <code>scripts/verify_access.sh</code> — 3 phép kiểm:
533	        ProxyJump vào VM trong từng vùng (wan/dmzfront/dmzapp/trusted/mgmt), <code>vmrun start</code> từ xa, và
534	        <code>tailscale status</code> hiện <code>direct</code>. <strong>Bước ProxyJump trượt thì dừng ngay</strong> và bàn lại:
535	        hoặc chuyển sang mô hình ngồi chung một máy (giữ nguyên 14 kịch bản), hoặc quay lại phương án cáp. Không mò quá 60 phút.</td></tr>
536	</table>
537	
538	<h3>GĐ1 — Perimeter cơ bản &amp; mô hình chính sách (ngày 2–4) · 12h</h3>
539	<table>
540	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
541	    <tr><td>H02</td><td><strong>Hùng</strong></td>
542	        <td>OPNsense 5 vNIC, đặt <code>descr</code> đúng tên zone trong YAML. Alias/zone tạo tay để kiểm mô hình.
543	        DNAT 443 WAN → LB VIP. Routing 2 chiều + default gateway. GUI HTTPS với cert tạm. Chưa có LB thì test bằng
544	        <code>nc -lvnp 443</code> trên lb1.</td>
545	        <td>6</td><td><code>curl -k https://10.0.0.100</code> từ attacker chạm tới dịch vụ giả</td></tr>
546	    <tr><td>B04</td><td><strong>Bảo</strong></td>
547	        <td>Viết <code>policy/zones.yml</code> + <code>aliases</code> + <code>rules[]</code>: mỗi rule có <code>id: POL-xxx</code>,
548	        <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>. Thêm alias <code>ADMIN_SRC</code> (10.0.0.6)
549	        cho đường bastion. Kèm schema validation + <code>yamllint</code>. Lập bảng 24 combo (zone, đích, port) làm nguồn chân lý cho T-07.</td>

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 550,
  "limit": 180,
  "pages": ""
}
```

**Response:**

550	        <td>5</td><td>YAML được cả hai duyệt; <code>make policy-lint</code> xanh</td></tr>
551	    <tr><td>B05</td><td><strong>Bảo</strong></td>
552	        <td>Route MGMT xuyên 2 máy + rule permit MGMT → các vùng cho scrape/SSH/syslog (POL-006, POL-007). Bảo thêm vào YAML, Hùng áp dụng.</td>
553	        <td>1</td><td><code>obs</code> thu thập được từ MGMT sang DMZ-FRONT</td></tr>
554	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Hùng <em>xoá toàn bộ</em> alias/rule tạo tay và thay bằng đúng mô hình YAML của Bảo.
555	        Đây là lần đầu "chính sách là mã nguồn" được chứng minh — làm ở ngày 4, không dồn sang GĐ2.</td></tr>
556	</table>
557	
558	<h3>GĐ2 — CARP + renderer API + HAProxy (ngày 4–6) · 20h</h3>
559	<table>
560	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
561	    <tr><td>H03</td><td><strong>Hùng</strong></td>
562	        <td>CARP 5 vhid (WAN, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT), advskew 0/100, tắt <code>preempt</code>.
563	        <strong>pfsync chạy trên vmnet-sync</strong>, không để qua WAN. cfgsync với user quyền tối thiểu.
564	        Test T-04 (iperf3 + ssh đang chạy phải sống sót), T-05 (cắt vmnet-sync → không có 2 MASTER),
565	        T-06 (sửa tay trên backup → master không bị ghi đè im lặng).</td>
566	        <td>8</td><td>T-04, T-05, T-06 pass kèm số liệu</td></tr>
567	    <tr><td>B06</td><td><strong>Bảo</strong></td>
568	        <td><em>Bước 0 (30 phút, bắt buộc):</em> bật API trên OPNsense, <code>curl</code> 3 endpoint
569	        (<code>searchAlias</code>, <code>rule_filter/addRule</code>, <code>filter/apply</code>) để xác nhận tên theo đúng phiên bản.
570	        Rồi viết renderer YAML → API, idempotent (chạy 2 lần ra cùng rule set; xoá khỏi YAML thì rule biến mất trên thiết bị).
571	        Apply + reload, đo số state trước/sau để chứng minh NFR-02.</td>
572	        <td>6</td><td>T-08 pass: thêm rule lúc 30 req/s, 0 gián đoạn, state không giảm</td></tr>
573	    <tr><td>H04</td><td><strong>Hùng</strong></td>
574	        <td>HAProxy ×2: TLS termination (ALPN h2), mTLS xuống backend, <code>option httpchk GET /healthz</code> +
575	        <code>expect status 200</code>, stats bind MGMT. Đóng role Ansible.
576	        <em>(Chuyển từ Bảo sang Hùng để cân giờ — HAProxy chạy trên VM của Hùng.)</em></td>
577	        <td>6</td><td>Handshake qua VIP OK; backend không có client cert hợp lệ thì bị từ chối</td></tr>
578	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy renderer lên thiết bị của Hùng (lần đầu có mặt Hùng).
579	        Rủi ro lớn nhất của cả dự án nằm ở đây: nếu API không như mong đợi thì kích hoạt phương án B (render <code>config.xml</code> + reboot) —
580	        độ khó policy tụt 4.7 xuống 4.2 nhưng lịch trình sống.</td></tr>
581	</table>
582	
583	<h3>GĐ3 — IPS inline + dịch vụ + DB nền (ngày 6–8) · 22h</h3>
584	<table>
585	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
586	    <tr><td>H05</td><td><strong>Hùng</strong></td>
587	        <td>Suricata <strong>inline NFQUEUE</strong> trên WAN + DMZ-FRONT + DMZ-APP; ruleset (emerging + tự viết cho hành vi lab);
588	        đo latency tăng thêm và số state bị ảnh hưởng.</td>
589	        <td>6</td><td>nmap từ attacker sinh alert và bị chặn theo rule đã bật</td></tr>
590	    <tr><td>H06</td><td><strong>Hùng</strong></td>
591	        <td>PostgreSQL ×2 streaming replication, <code>synchronous_commit=on</code>, <code>hostssl</code> + scram, replication slot.</td>
592	        <td>4</td><td><code>pg_stat_replication</code> thấy standby; ghi primary thì đọc được ở standby</td></tr>
593	    <tr><td>B07</td><td><strong>Bảo</strong></td>
594	        <td>Policy validator: quét 24 combo từ attacker/sensor/web/db, so với YAML, đọc counter từng rule, xuất CSV. Thêm <code>make drift</code>.</td>
595	        <td>4</td><td>T-07 pass 24/24; mọi rule được kiểm đều có counter &gt; 0</td></tr>
596	    <tr><td>B08</td><td><strong>Bảo</strong></td>
597	        <td>Keepalived VIP multicast (vmnet của VMware xử lý được, không cần <code>unicast_peer</code>) +
598	        <code>track_script</code> gọi <code>haproxy -c</code>.</td>
599	        <td>3</td><td>T-03 pass: VIP đổi chủ ≤ 10 s</td></tr>
600	    <tr><td>B09</td><td><strong>Bảo</strong></td>
601	        <td>App 4 endpoint (<code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code>, <code>/session</code>),
602	        session lưu trong DB, Apache ×2 + hardening (SSH key-only, ẩn banner, CSP/HSTS), role Ansible.</td>
603	        <td>5</td><td>T-01, T-02 pass; phiên còn sau khi chết 1 web node</td></tr>
604	    <tr><td colspan="5"><strong>Checkpoint 1 (hết ngày 8):</strong> T-01, T-02, T-03, T-04, T-07 pass.
605	        Nếu T-04 hoặc T-07 chưa đạt thì cắt phạm vi <em>ngay bây giờ</em>, không phải ngày 12.</td></tr>
606	</table>
607	
608	<h3>GĐ4 — An ninh sâu + khôi phục (ngày 8–10) · 20.5h</h3>
609	<table>
610	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
611	    <tr><td>H07</td><td><strong>Hùng</strong></td>
612	        <td><code>promote.sh</code>: repmgr promote → gán DB VIP + <code>arping -A</code> → refresh alias firewall →
613	        <strong>fence</strong> node cũ (stop postgres + rule chặn 5432 từ IP của nó). Test <code>kill -9</code>, đo RTO và RPO.</td>
614	        <td>5</td><td>T-13a: leader mới ≤ 40 s, commit cuối còn, node cũ không ghi được</td></tr>
615	    <tr><td>H08</td><td><strong>Hùng</strong></td>
616	        <td><code>mod_security2</code> + OWASP CRS, <code>SecRuleEngine On</code>, ParanoiaLevel 2,
617	        file overrides trong Git mỗi rule có <code>Reason:</code>.</td>
618	        <td>4</td><td>T-12: 15 request hợp lệ → 0 block sai</td></tr>
619	    <tr><td>H09</td><td><strong>Hùng</strong></td>
620	        <td>Test <strong>fail-closed</strong>: dừng Suricata khi đang có kết nối → xác nhận hành vi (chặn hay mở),
621	        thêm alert "IPS xuống", viết đoạn công bố hành vi + lý do lựa chọn.</td>
622	        <td>2</td><td>T-10 pass + có đoạn văn thiết kế</td></tr>
623	    <tr><td>H10</td><td><strong>Hùng</strong></td>
624	        <td>Chống flood ở perimeter: <code>max-src-conn</code>, state table limit, syncookies; test SYN flood từ attacker.</td>
625	        <td>2</td><td>T-14a: 50k pkt/s không làm sập VIP, có số liệu state table</td></tr>
626	    <tr><td>H11</td><td><strong>Hùng</strong></td>
627	        <td>Hardening thiết bị biên: tắt service thừa, GUI TLS cert nội bộ, khoá root shell, anti-spoofing, bogon,
628	        private-network, NTP, backup <code>config.xml</code> có mã hoá.</td>
629	        <td>2</td><td>Checklist NFR-11 đạt, kèm ảnh trước/sau</td></tr>
630	    <tr><td>B10</td><td><strong>Bảo</strong></td>
631	        <td><strong>Tài liệu hoá out-of-band management path</strong> (mục 2.4 #7): viết rõ đường điều khiển đi qua
632	        hypervisor host chứ không qua perimeter, liệt kê hệ quả với NFR-13, và kiểm bastion vẫn còn nghĩa bằng test
633	        "attacker từ vmnet-wan thử SSH vào bastion phải bị từ chối"</td>
634	        <td>0.5</td><td>Có đoạn văn trong báo cáo + kết quả test SSH-from-WAN = block</td></tr>
635	    <tr><td>B11</td><td><strong>Bảo</strong></td>
636	        <td>step-ca: 2 authority (server + client), TTL 7 ngày, script gia hạn, cert cho lb/web phục vụ mTLS.</td>
637	        <td>3</td><td>mTLS dùng cert nội bộ, không còn cert tự sinh tạm</td></tr>
638	    <tr><td>B12</td><td><strong>Bảo</strong></td>
639	        <td>Remote syslog 3 nguồn (firewall, WAF, app) → Loki; index theo <code>POLICY-ID</code> và <code>X-Request-ID</code>.</td>
640	        <td>2</td><td>Truy vết được 1 request xuyên LB → web → DB bằng log</td></tr>
641	    <tr><td colspan="5"><strong>Checkpoint 2 (hết ngày 10):</strong> T-09, T-10, T-11, T-12, T-13 pass.
642	        Nếu T-13 chưa đạt, chạy bảng cắt khẩn cấp ở mục 11 <em>trong ngày 10</em>.</td></tr>
643	</table>
644	
645	<h3>GĐ5 — Kiểm chứng tấn công &amp; quan sát (ngày 10–12) · 16h</h3>
646	<table>
647	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
648	    <tr><td>B13</td><td><strong>Bảo</strong></td>
649	        <td>Prometheus + node/haproxy/postgres exporter, Grafana 3 dashboard (Dịch vụ / Perimeter+IPS / DB),
650	        Alertmanager 6 alert: mất MASTER CARP, IPS xuống, rule counter bất thường, 5xx&gt;1%, DB leader đổi, backup &gt;24h.</td>
651	        <td>4</td><td>Ít nhất 1 alert bắn thật trong điều kiện test</td></tr>
652	    <tr><td>B14</td><td><strong>Bảo</strong></td>
653	        <td>Attack harness 4 lớp từ <code>attacker</code>: (1) scan, (2) 30 payload web, (3) SSH brute force, (4) egress attempt từ web ra WAN.
654	        Mỗi lớp lấy bằng chứng từ <code>sensor</code> (tcpdump/Zeek) rồi đối chiếu log phòng thủ → bảng "gửi gì / ghi nhận gì / lệch ở đâu".
655	        Map MITRE: T1046, T1190, T1110, T1048, T1562.110.</td>
656	        <td>7</td><td>T-09, T-14 pass; bảng đối chiếu sensor-vs-defender hoàn chỉnh</td></tr>
657	    <tr><td>H12</td><td><strong>Hùng</strong></td>
658	        <td>pgBackRest: WAL archive + full + incremental lên repo (ssh/NFS sang obs). <strong>Diễn tập PITR</strong> tới timestamp
659	        chỉ định trên instance mới, verify 3 bản ghi mốc.</td>
660	        <td>5</td><td>T-13b pass + biên bản thời gian và dung lượng WAL</td></tr>
661	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy attack harness <em>trong khi</em> Hùng chạy PITR.
662	        Đây là lần duy nhất hai người thao tác đồng thời, và là phép thử thật cho việc lab có đứng dưới tải tấn công hay không.</td></tr>
663	</table>
664	
665	<h3>GĐ6 — Test, rebuild, báo cáo (ngày 12–14) · 16h</h3>
666	<table>
667	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
668	    <tr><td>H13</td><td><strong>Hùng</strong></td><td>Chạy lại 8 kịch bản phần biên: T-04, T-05, T-06, T-08, T-10, T-11, T-13, T-14a</td><td>3</td><td>8/8 pass, có CSV</td></tr>
669	    <tr><td>B15</td><td><strong>Bảo</strong></td><td>Chạy lại 6 kịch bản phần dịch vụ: T-01, T-02, T-03, T-07, T-09, T-12</td><td>3</td><td>6/6 pass</td></tr>
670	    <tr><td>B16</td><td><strong>Bảo</strong></td><td><code>run_matrix.sh</code> + schema CSV + <code>report.py</code> dựng bảng và biểu đồ</td><td>2</td><td>Một lệnh ra toàn bộ số liệu</td></tr>
671	    <tr><td>H14 / B17</td><td><strong>Mỗi người 1.5</strong></td><td>Rebuild drill ≤ 30 phút: xoá dịch vụ, dựng lại bằng Ansible, chạy lại test chính</td><td>3</td><td>Biên bản thời gian + kết quả test sau dựng</td></tr>
672	    <tr><td>B18</td><td><strong>Bảo</strong></td><td>Báo cáo: mô hình chính sách, policy-as-code, bằng chứng sensor-vs-log, bảng MITRE, trade-off đã cắt</td><td>3</td><td>Bản nháp hoàn chỉnh</td></tr>
673	    <tr><td>H15</td><td><strong>Hùng</strong></td><td>Báo cáo phần perimeter/CARP/IPS/PITR + video demo 6 kịch bản (T-04, T-08, T-09, T-10, T-13, T-14)</td><td>2</td><td>Video + snapshot <code>green</code> cuối</td></tr>
674	</table>
675	
676	<h3>Tổng kết phân công</h3>
677	<table>
678	    <tr><th>Giai đoạn</th><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Tổng</th><th>Điều kiện ra</th></tr>
679	    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
680	    <tr><td>GĐ1 Perimeter + mô hình</td><td>2–4</td><td>6</td><td>6</td><td>12</td><td>curl chạm dịch vụ giả; YAML được duyệt</td></tr>
681	    <tr><td>GĐ2 CARP + renderer + LB</td><td>4–6</td><td>14</td><td>6</td><td>20</td><td>T-04, T-05, T-06, T-08</td></tr>
682	    <tr><td>GĐ3 IPS + dịch vụ + DB nền</td><td>6–8</td><td>10</td><td>12</td><td>22</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-07</td></tr>
683	    <tr><td>GĐ4 An ninh sâu + khôi phục</td><td>8–10</td><td>15</td><td>5.5</td><td>20.5</td><td><strong>Checkpoint 2</strong>: T-09 tới T-13</td></tr>
684	    <tr><td>GĐ5 Kiểm chứng + quan sát</td><td>10–12</td><td>5</td><td>11</td><td>16</td><td>T-14 + PITR + alert thật</td></tr>
685	    <tr><td>GĐ6 Test + báo cáo</td><td>12–14</td><td>6.5</td><td>9.5</td><td>16</td><td>14/14 pass + video</td></tr>
686	    <tr><td><strong>Tổng</strong></td><td></td><td><strong>60</strong></td><td><strong>55.5</strong></td><td><strong>115.5</strong></td><td>82% quỹ, 24.5 giờ đệm</td></tr>
687	</table>
688	<div class="note">
689	<strong>Hai người cố tình không đối xứng.</strong> Hùng tập trung giờ ở GĐ2 + GĐ4 (29h) vì đó là CARP và an ninh sâu — phần cần hiểu thiết bị.
690	Bảo tập trung ở GĐ0 + GĐ3 + GĐ5 (28h) vì đó là control plane, validator và kiểm chứng tấn công — phần cần viết code và chạy script.
691	Chia đối xứng sẽ buộc một người phải làm việc của người kia ở trình độ thấp hơn.
692	</div>
693	
694	<h2>10. Lịch 14 ngày theo mã việc</h2>
695	<table>
696	    <tr><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Mốc chung cuối ngày</th></tr>
697	    <tr><td>1</td><td>H01 VMware + 12 VM + 6 vmnet riêng</td><td>B01 Tailscale 2 máy + tắt key expiry + OpenSSH Server trên Hùng</td><td><code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào được 1 VM bất kỳ</td></tr>
698	    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>
699	    <tr><td>3</td><td>H02 OPNsense 5 vùng + DNAT 443→LB VIP</td><td>B04 YAML policy + bảng 24 combo</td><td>attacker chạm được dịch vụ giả qua perimeter</td></tr>
700	    <tr><td>4</td><td>H02 routing + H03 CARP vhid</td><td>B04 tiếp, B05 route MGMT nội bộ + rule bastion</td><td><strong>Giao YAML cho Hùng, xoá toàn bộ rule tạo tay</strong></td></tr>
701	    <tr><td>5</td><td>H03 pfsync state sync</td><td>B06 <em>verify API 30 phút</em> rồi renderer</td><td>API xanh, hoặc quyết định phương án B (<code>config.xml</code>)</td></tr>
702	    <tr><td>6</td><td>H03 cfgsync, H04 HAProxy TLS/mTLS</td><td>B06 renderer + apply dưới tải</td><td>T-04 pass (session sống sót), T-08 pass</td></tr>
703	    <tr><td>7</td><td>H04 HAProxy + H06 PostgreSQL streaming</td><td>B09 app + web ×2</td><td>T-01, T-02 pass</td></tr>
704	    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
705	    <tr><td>9</td><td>H07 promote/fencing, H08 CRS, H09 fail-closed</td><td>B10 tài liệu hoá out-of-band mgmt path, B11 step-ca</td><td>T-09, T-10, T-12 pass</td></tr>
706	    <tr><td>10</td><td>H10 state limit, H11 hardening, H12 PITR (bắt đầu)</td><td>B12 syslog → Loki</td><td><strong>Checkpoint 2</strong>: T-13, T-14 pass</td></tr>
707	    <tr><td>11</td><td>H12 PITR drill + verify</td><td>B13 Prometheus/Grafana/6 alert, B14 attack harness + sensor</td><td>Chạy đủ 14 kịch bản lần đầu</td></tr>
708	    <tr><td>12</td><td>H13 chạy lại 8 kịch bản biên, H14 rebuild drill</td><td>B15 chạy lại 6 kịch bản dịch vụ, B16 <code>run_matrix.sh</code>, B17 rebuild drill</td><td>14/14 pass hoặc ghi chú fail trung thực</td></tr>
709	    <tr><td>13</td><td>H15 báo cáo perimeter + video demo</td><td>B18 báo cáo chính sách + MITRE + trade-off</td><td>Bản nháp hoàn chỉnh + video dự phòng</td></tr>
710	    <tr><td>14</td><td colspan="2">Dự phòng: chạy lại test cuối, luyện phản biện phần của đối phương</td><td>Sẵn sàng nộp</td></tr>
711	</table>
712	<div class="note">
713	<strong>Hai ngày then chốt.</strong> Ngày 1 chỉ có một việc thật: xác nhận ProxyJump vào được VM — mất 20 phút, và nếu không xong thì
714	dừng lại bàn phương án khác trước khi đầu tư thêm. Ngày 5 là bước <em>verify API OPNsense</em>: trượt ở đây bạn còn 3 ngày
715	để đổi sang render <code>config.xml</code> + reboot; thử ở ngày 8 thì không còn đường lùi.
716	</div>
717	
718	<h2>11. Bảng cắt khẩn cấp (kích hoạt ở Checkpoint 1 hoặc 2)</h2>
719	<table>
720	    <tr><th>Thứ tự</th><th>Cắt</th><th>Giờ giữ lại</th><th>Độ khó sau cắt</th></tr>
721	    <tr><td>1</td><td>H10 state limit + SYN flood</td><td>2</td><td>Perimeter 4.5 → 4.3</td></tr>
722	    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
723	    <tr><td>3</td><td>B14 phần đối chiếu sensor-vs-defender (chỉ dùng log phòng thủ)</td><td>3</td><td>Attack validation 4.2 → 3.9</td></tr>
724	    <tr><td>4</td><td>H09 test fail-closed (chuyển thành mô tả thiết kế + lý do)</td><td>2</td><td>IPS 4.6 → 4.3</td></tr>
725	    <tr><td>5</td><td>H08 CRS xuống DetectionOnly + còn 10 payload</td><td>2</td><td>WAF 4.2 → 3.6 ⚠</td></tr>
726	    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
727	    <tr><td colspan="2"><strong>TUYỆT ĐỐI KHÔNG CẮT</strong></td>
728	        <td colspan="2">H03 (CARP + pfsync), B06 (policy-as-code + apply không gián đoạn), H05 (IPS blocking),
729	        B07 (ma trận chính sách) — bốn thứ định danh bản v4. Cắt một trong bốn thì nên nộp bản v3.</td></tr>

#### Tool: Glob

**Input:**

```json
{
  "pattern": "docs/**",
  "path": "D:\\Lab"
}
```

**Response:**

No files found

#### Thinking

**Planning project deployment steps****Preparing plan document creation steps****Verifying directory existence before creation**

#### Thinking

**Planning multi-step task creation**

Tài liệu đã có sẵn lịch 14 ngày, 7 giai đoạn, 12 VM, 14 test và bảng cắt khẩn cấp; mình sẽ giữ các mốc đó nhưng bổ sung phần thực thi an toàn cho môi trường hiện tại: WSL control plane nhẹ, VMware giữ topology L2, và checkpoint trước mọi thao tác phá hủy hoặc tốn quota. Mình sẽ ghi kế hoạch thành file để bạn dùng như runbook.

#### Thinking

**Planning directory existence check****Verifying directory existence with Bash**

Mình đã chốt cấu trúc kế hoạch: 7 phase theo tài liệu gốc, nhưng mỗi phase sẽ có “ai làm”, “lệnh/đầu vào”, “pass/fail”, “điểm dừng” và “rollback”. Mình kiểm tra thư mục đích trước khi ghi runbook, chưa đụng vào cấu hình hệ thống.

#### Tool: Bash

**Input:**

```json
{
  "command": "ls -la",
  "description": "Kiểm tra thư mục workspace trước khi tạo kế hoạch",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

total 196
drwxr-xr-x 1 Administrator 197121     0 Nov  7 10:04 .
drwxr-xr-x 1 Administrator 197121     0 Nov  6 09:50 ..
-rw-r--r-- 1 Administrator 197121 67298 Nov  7 09:50 ha-lb-security-lab.html

#### Tool: Bash

**Input:**

```json
{
  "command": "ls -la docs 2>/dev/null || true; ls -la docs/superpowers 2>/dev/null || true; ls -la docs/superpowers/plans 2>/dev/null || true",
  "description": "Kiểm tra thư mục lưu kế hoạch",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

(Bash completed with no output)

#### Thinking

**Adding directory creation command**

#### Tool: Bash

**Input:**

```json
{
  "command": "mkdir -p \"docs/superpowers/plans\"",
  "description": "Tạo thư mục lưu kế hoạch triển khai",
  "dir_path": "D:\\Lab",
  "run_in_background": false,
  "timeout": 120000
}
```

**Response:**

(Bash completed with no output)

#### Thinking

**Outlining detailed file creation plan****Defining granular step-by-step WSL command plan****Evaluating specialized planning agent integration**

#### Thinking

**Planning agent delegation for architecture review**

Mình sẽ nhờ một planner độc lập rà lại thứ tự phụ thuộc và các điểm dễ làm hỏng lab, rồi dùng kết quả đó để tránh kế hoạch quá lý tưởng hoặc thiếu rollback.

#### Tool: Agent

**Input:**

```json
{
  "description": "Rà soát kế hoạch lab",
  "prompt": "Hãy lập/kiểm tra kế hoạch triển khai theo từng phase cho lab được mô tả trong D:\\Lab\\ha-lb-security-lab.html. Bối cảnh môi trường: Windows 11 Pro, 32 GB RAM, i5-12500H/16 luồng, RTX 3050 4 GB; VMware Workstation đã cài; hiện chỉ thấy VMnet1/VMnet8; WSL2 có Kali/Arch/Ubuntu ở D:\\WSL, .wslconfig cấp 14 GB RAM/10 vCPU/16 GB swap, vmmemWSL đang dùng khoảng 13-14 GB; D:\\Lab chỉ có file HTML, chưa có repo hay code; Ansible/Docker/Podman/Tailscale trong WSL chưa cài; Windows OpenSSH/Tailscale đang stopped. Dự án mục tiêu: 12 VM (2 OPNsense, 2 HAProxy, 2 web, 2 PostgreSQL, obs, ca, attacker, sensor), 6 vmnet private, Tailscale control plane, CARP/pfsync, policy-as-code, Suricata inline, HAProxy/Keepalived, PostgreSQL replication/PITR, Loki/Prometheus/Grafana, 14 test. Chỉ nghiên cứu/đề xuất, không sửa file. Báo cáo bằng tiếng Việt, tập trung: thứ tự phụ thuộc, checkpoint pass/fail, rollback/cắt phạm vi, việc assistant có thể làm trong workspace vs user phải thao tác trên Windows/VMware/VM consoles, và các giả định cần user xác nhận. Không cần viết code hay tài liệu dài.",
  "subagent_type": "Plan",
  "mode": "default",
  "run_in_background": false,
  "name": "plan-review",
  "team_name": "",
  "isolation": "default"
}
```

**Response:**

Kế hoạch trong `D:\Lab\ha-lb-security-lab.html` có cấu trúc tốt, nhưng chưa sẵn sàng triển khai nguyên trạng trên môi trường hiện tại. Phụ thuộc lớn nhất là: dựng được 6 vmnet, giảm áp lực RAM WSL2, xác nhận đường `Tailscale → Windows OpenSSH → ProxyJump → VM`, rồi mới đầu tư vào OPNsense/CARP.

**Kết luận kiểm tra nhanh**

- Không nên bắt đầu bằng việc tạo đủ 12 VM rồi bật đồng thời. Tổng RAM thiết kế là khoảng 17 GB khi bật đủ, cộng WSL2 đang dùng 13–14 GB, Windows/VMware và cache sẽ vượt biên an toàn của máy 32 GB.
- Chưa thể coi `VMnet1/VMnet8` là đủ. Cần tạo thêm các mạng private riêng: WAN, SYNC, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT. Đây là thao tác trên Windows/VMware, assistant không thể thực hiện trong workspace.
- `Tailscale` không thay thế L2. Phương án ProxyJump chỉ hợp lệ nếu Windows host có adapter trên từng vmnet và có thể TCP-connect tới VM. Phải kiểm tra thực tế trước khi tạo policy.
- NFR-13 trong tài liệu bị hạ cấp về ý nghĩa: `obs`, `ca`, `sensor` vẫn cùng máy vật lý với dịch vụ. Nên ghi rõ đây là phân tách logic, không phải giám sát ngoài host.
- Mốc “T-04 session TCP không đứt qua CARP failover” cần xem là mục tiêu thử nghiệm, không phải giả định. pfsync/CARP trên VMware host-only phải được chứng minh sớm.
- Kế hoạch hiện nói “Ansible ping đủ 12 VM” trước khi chỉ rõ image, IP, SSH user/key và cách cấp IP cho OPNsense. Nên tách kiểm tra reachability của OPNsense khỏi Linux VM.

## Thứ tự phase đề xuất

### Phase 0 — Dọn điều kiện máy chủ và quyết định phạm vi

**Mục tiêu**

Xác nhận máy đủ sức chạy lab theo từng nhóm VM, không cố dựng toàn bộ ngay.

**Việc user phải làm trên Windows**

- Bật Windows OpenSSH Server, đặt `Automatic`, cấu hình key-only.
- Cài và đăng nhập Tailscale trên hai máy; tắt key expiry nếu chính sách tailnet cho phép.
- Đặt Windows High Performance, không sleep khi chạy lab.
- Tạo 6 custom private vmnet trong VMware, không bridged:
  - WAN `10.0.0.0/24`
  - SYNC `192.168.50.0/24`
  - DMZ-FRONT `192.168.20.0/24`
  - DMZ-APP `192.168.21.0/24`
  - TRUSTED `192.168.30.0/24`
  - MGMT `192.168.99.0/24`
- Xác nhận host adapter của Windows tồn tại trên các vmnet cần dùng.

**Điều chỉnh tài nguyên**

Tạm đặt WSL2 thấp hơn, ví dụ 8–10 GB và 6–8 vCPU trong giai đoạn chạy VM. Không nên chạy WSL2 ở mức 14 GB khi obs/Grafana/DB/OPNsense đang bật.

Nên dùng các profile bật VM:

- `core`: 2 OPNsense, 2 LB, 2 web, 2 PostgreSQL, khoảng 10–12 GB.
- `observe`: thêm `obs`, `ca`, khoảng 13–15 GB.
- `attack`: thêm `attacker`, `sensor` chỉ khi test, khoảng 16–19 GB.
- Tắt attacker/sensor sau từng test như tài liệu đã quy định.

**Checkpoint P0 — Pass/Fail**

Pass khi:

- 6 vmnet tồn tại đúng subnet, không bridged.
- Host Windows ping/TCP-connect được tới một VM thử trên từng vùng.
- Bảo SSH được vào Windows Hùng qua Tailscale.
- `ssh -J` vào được ít nhất một VM Linux.
- WSL2 + VM core giữ ổn định ít nhất 30 phút, không paging/thrashing nghiêm trọng.

Fail thì chưa tạo 12 VM hoàn chỉnh. Rollback là giữ lại 2 OPNsense + 1 LB + 1 web làm vertical slice, hoặc chuyển sang làm chung trực tiếp trên máy Hùng.

**Ai làm được trong workspace**

Assistant có thể giúp thiết kế inventory, ma trận IP, checklist kiểm tra, cấu trúc repo và lệnh xác minh sau khi user đã tạo môi trường. Hiện `D:\Lab` chưa có repo nên chưa có gì để tự chạy.

### Phase 1 — Tạo VM theo lát dọc tối thiểu

Không nên tạo 12 VM cùng lúc. Thứ tự nên là:

1. `opns1`, `opns2`
2. `lb1`, `lb2`
3. `web1`, `web2`
4. `pg1`, `pg2`
5. `obs`, `ca`
6. `attacker`, `sensor`

Mỗi nhóm chỉ thêm sau khi nhóm trước đạt checkpoint. Dùng linked clone nếu template đã được chuẩn bị và kiểm tra tương thích; nếu chưa có template, snapshot sạch đáng tin cậy quan trọng hơn việc cố làm linked clone ngay.

**Checkpoint P1**

- Mỗi VM có đúng NIC và đúng vmnet.
- Không có NIC nào vô tình nối vào bridged/NAT ngoài dự kiến.
- IP, gateway, hostname, NTP được ghi lại.
- Snapshot `clean` tồn tại trước khi cấu hình dịch vụ.

Rollback: xóa khỏi inventory nhóm VM chưa cần, giữ lại core profile. Không cần dựng attacker/sensor để chứng minh routing cơ bản.

### Phase 2 — OPNsense một node trước, rồi mới HA

Thứ tự trong tài liệu nên đảo nhẹ:

1. Cấu hình `opns1` với 5 zone và interface sync.
2. Kiểm tra routing và DNAT tới dịch vụ giả trên LB.
3. Tạo alias/policy tối thiểu thủ công.
4. Cấu hình `opns2`.
5. CARP theo từng zone.
6. pfsync trên `vmnet-sync`.
7. cfgsync sau khi CARP và pfsync ổn định.

Không nên bật Suricata, policy renderer hoặc flood test trong phase này.

**Checkpoint P2**

- Attacker tới được dịch vụ giả qua WAN → DNAT → DMZ-FRONT.
- WAN không tới được DB/MGMT trái phép.
- GUI chỉ qua HTTPS.
- Hai node OPNsense nhìn thấy nhau trên sync.
- Có đúng một CARP master mỗi VIP.
- Cắt sync không tạo split-brain.
- Session dài qua failover được đo bằng số liệu, không chỉ quan sát bằng mắt.

**Rollback**

- Tắt cfgsync, quay snapshot trước HA.
- Dùng một OPNsense để tiếp tục phát triển app/policy nếu CARP chưa ổn.
- Không chuyển sang IPS khi T-04 chưa có kết quả.

### Phase 3 — Repo, policy-as-code và API OPNsense

Đây là một critical path và phải làm “spike” trước renderer đầy đủ.

**Thứ tự**

1. Xác nhận phiên bản OPNsense giống nhau trên cả hai node.
2. Tạo API key quyền tối thiểu.
3. Gọi thử các endpoint alias, rule và apply.
4. Ghi lại response thực tế của phiên bản đang dùng.
5. Chỉ sau đó mới thiết kế renderer idempotent.
6. Thêm validator 24 combo và drift check.
7. Xóa rule tạo tay, để YAML trở thành nguồn chân lý duy nhất.

**Checkpoint P3**

- `policy-lint` pass.
- Apply lần đầu thành công.
- Apply lần hai không tạo bản sao.
- Xóa một rule trong YAML làm rule biến mất trên thiết bị.
- Thêm rule dưới tải không làm mất state hoặc tạo 5xx.
- Mỗi rule có `POLICY-ID`, log và test mapping.

**Rollback**

Phương án B trong tài liệu — render `config.xml` — chỉ nên là fallback có kiểm soát, không dùng reboot như đường triển khai thường xuyên. Nếu API không dùng được, giữ policy YAML/validator nhưng đánh dấu NFR-02 “chưa đạt đầy đủ”, thay vì giả vờ có apply không gián đoạn.

### Phase 4 — LB, web và DB nền

Thứ tự nên là:

1. HAProxy một node với backend web.
2. Web health check và mTLS.
3. HAProxy thứ hai và Keepalived VIP.
4. PostgreSQL streaming replication.
5. Session lưu DB.
6. DB VIP và cơ chế promote/fence.
7. PITR.

Không nên chạy failover DB trước khi có:

- fencing rõ ràng;
- cách xác định node cũ không còn ghi;
- xác nhận app chỉ dùng DB VIP;
- backup repository trên `obs`.

**Checkpoint P4**

- T-01, T-02, T-03 pass.
- Web không có client certificate hợp lệ bị từ chối.
- Session còn sau khi một web node chết.
- PostgreSQL standby theo kịp.
- DB failover không tạo hai writer.
- PITR khôi phục được ba bản ghi mốc.

Rollback/cắt phạm vi:

1. Bỏ state-limit/SYN flood trước.
2. Gộp sensor vào attacker nếu thiếu RAM.
3. Bỏ auto DB failover nhưng giữ streaming + manual promote + PITR.
4. Không bỏ DB VIP nếu mục tiêu vẫn là chứng minh app không đổi connection string.

### Phase 5 — IPS/WAF và observability

Chỉ bật inline IPS sau khi có snapshot `IPS-off` và core path đã chạy ổn.

**Thứ tự**

1. Suricata detection-only để xác nhận traffic path.
2. Bật blocking trên WAN.
3. Mở rộng sang DMZ-FRONT.
4. Cuối cùng mới DMZ-APP.
5. Kiểm tra fail-closed/fail-open theo hành vi thực tế.
6. Cấu hình WAF CRS.
7. Gửi log về obs.
8. Thêm Prometheus/Grafana/alert sau khi log cơ bản đã ổn.

**Checkpoint P5**

- Scan tạo alert và bị chặn theo thiết kế.
- Dừng Suricata có hành vi đã công bố và có alert.
- 15 request hợp lệ không bị WAF chặn sai.
- Có ít nhất một alert thật từ CARP/IPS/DB.
- Có thể truy vết một request từ LB qua web tới DB.
- Sensor chứng minh được “đã gửi gì”; defender log chứng minh “đã xử lý gì”.

Rollback:

- Tắt blocking, quay `IPS-off`, giữ detection-only nếu inline làm hỏng lab.
- Hạ CRS về DetectionOnly nếu false positive phá T-01/T-02.
- Bỏ dashboard đẹp trước, giữ raw logs và một alert có bằng chứng.

### Phase 6 — Attack validation, ma trận 14 test và rebuild

Chạy test theo thứ tự ít phá hoại đến phá hoại:

1. T-01, T-02, T-03
2. T-07, T-08
3. T-04, T-05, T-06
4. T-09, T-11, T-12
5. T-13
6. T-10
7. T-14

Mỗi test cần snapshot `before-T-xx`, timestamp đồng bộ, trạng thái `direct/DERP` của Tailscale nếu có đo timing, và kết quả pass/fail rõ ràng.

**Checkpoint cuối**

- 14 test có kết quả, không nhất thiết 14/14 pass.
- Mỗi fail có nguyên nhân, ảnh hưởng, workaround và phạm vi bị hạ cấp.
- Rebuild drill đo từ trạng thái xác định, không tính thời gian tải ISO hoặc sửa thủ công ngoài quy trình.
- NFR-13 phải ghi là “logical separation on one physical host”, không trình bày như độc lập vật lý.

## Các điểm cần sửa trong kế hoạch gốc

- “Tạo 12 VM ở GĐ0” không phù hợp với WSL2 đang dùng 13–14 GB; nên tạo theo profile và bật theo nhóm.
- “Ansible ping đủ 12 VM” quá sớm; OPNsense và Linux VM cần hai loại bootstrap/check khác nhau.
- `ADMIN_SRC: 10.0.0.6` chưa khớp rõ với topology Tailscale/Windows host. Cần xác nhận IP nguồn thực tế khi Windows host kết nối tới VM; không được đoán.
- Tài liệu nói sensor promiscuous trên vmnet WAN; cần kiểm tra VMware virtual switch có cho phép promiscuous/capture như mong muốn. Đây là việc user phải xác minh trên VMware, không nên coi là mặc định.
- Keepalived multicast trên VMware cần một smoke test nhỏ trước khi phụ thuộc vào T-03.
- T-06 “sửa tay trên backup” cần định nghĩa rõ expected behavior: cảnh báo drift, không tự ghi đè, và cách khôi phục cấu hình chuẩn.
- T-14 “50k pkt/s” có thể quá cao hoặc thiếu ý nghĩa trên một laptop/VM. Nên ghi cả tốc độ thực tế đạt được và giới hạn phần cứng; không tuyên bố đạt ngưỡng nếu generator không phát được tải.
- NFR-10 ghi “RPO = 0 khi mất DB primary” chỉ hợp lý trong điều kiện synchronous replication đã commit thành công; cần phân biệt commit đã xác nhận với giao dịch đang in-flight.
- Không nên cài thêm Ansible/Docker/Podman chỉ vì danh sách công nghệ. Với kế hoạch hiện tại, Ansible + các binary cần thiết là đủ; Docker/Podman chỉ thêm nếu một dịch vụ quan sát thực sự cần container.

## Việc user phải thao tác ngoài workspace

- Cấu hình Windows OpenSSH, Tailscale, firewall Windows và startup.
- Tạo/chỉnh custom vmnet trong VMware.
- Tạo VM, gắn NIC, cài OS/OPNsense, snapshot, power on/off.
- Kiểm tra VMware multicast/promiscuous behavior.
- Điều chỉnh `.wslconfig` và khởi động lại WSL2.
- Xác nhận tailnet policy, key expiry, kết nối direct/DERP.
- Thao tác console khi mất SSH, sai routing hoặc firewall tự khóa.
- Chạy các test phá hoại cần console/snapshot rollback.

## Việc assistant có thể làm trong workspace

Hiện chỉ có thể nghiên cứu và chuẩn bị kế hoạch vì `D:\Lab` chưa có repo. Sau khi user tạo repo hoặc cung cấp inventory, assistant có thể:

- Rà soát topology, IP plan và dependency graph.
- Thiết kế inventory Ansible, nhóm vùng và thứ tự bootstrap.
- Viết/kiểm tra policy schema, mapping 24 combo và test matrix.
- Kiểm tra cấu trúc playbook, idempotency, drift và các lệnh `make check`.
- Phân tích log, CSV test và bằng chứng sensor-vs-defender.
- Không thể tự bật VM, sửa VMware networking, cài phần mềm Windows hay xử lý console OPNsense.

## Giả định cần user xác nhận

1. Máy Hùng có đủ dung lượng SSD cho 12 VM, snapshot và WAL/PITR; RAM là giới hạn chính hiện tại.
2. VMware Workstation bản đang dùng hỗ trợ custom host-only networks cần thiết và multicast/VRRP theo thiết kế.
3. Windows host sẽ có adapter truy cập được từng vmnet; đây là điều kiện của ProxyJump.
4. Máy Bảo có quyền cài Tailscale, OpenSSH client và thay đổi WSL2.
5. Có thể giảm WSL2 từ 14 GB xuống trong lúc chạy lab.
6. Hai máy có cùng tailnet và Tailscale policy cho phép kết nối cần thiết.
7. `10.0.0.6` thực sự là nguồn quản trị được nhìn thấy từ OPNsense; nếu không, phải thay bằng alias nguồn đúng.
8. Mục tiêu chấp nhận NFR-13 ở mức phân tách logic, không yêu cầu độc lập vật lý.
9. Có thể dùng manual promote DB nếu automatic failover không đạt trong thời gian.
10. 14 test là mục tiêu kiểm chứng; không bắt buộc mọi test phải đạt nếu checkpoint ghi nhận hạ cấp trung thực.

**Phương án lười hơn:** trước mắt chỉ dựng một vertical slice `opns1 → lb1 → web1 → pg1`, xác nhận vmnet/ProxyJump/policy path trong một ngày; chỉ nhân bản thành HA và 12 VM khi slice này pass.

### Critical Files for Implementation
- `D:\Lab\ha-lb-security-lab.html`
- `D:\Lab\policy\zones.yml`
- `D:\Lab\ansible.cfg`
- `D:\Lab\inventory\hosts.yml`
- `D:\Lab\Makefile`

> D:\Lab\ha-lb-security-lab.html

[hook: SubagentStart] succeeded (exit 0)

#### Thinking

**Inspecting HTML in read-only mode**

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 1,
  "limit": 400,
  "pages": ""
}
```

**Response:**

1	<!DOCTYPE html>
2	<html lang="vi">
3	<head>
4	<meta charset="UTF-8">
5	<title>Đề tài Lab v4.2 — Firewall &amp; Security-First, 2 tuần, 1 máy host + Tailscale</title>
6	<style>
7	    body { font-family: "Times New Roman", Arial, sans-serif; line-height: 1.6; margin: 40px; color: #111; max-width: 1140px; }
8	    h1 { text-align: center; font-size: 22px; text-transform: uppercase; }
9	    h2 { font-size: 18px; margin-top: 30px; border-bottom: 2px solid #333; padding-bottom: 4px; }
10	    h3 { font-size: 16px; margin-top: 20px; }
11	    table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 14px; }
12	    th, td { border: 1px solid #000; padding: 7px 8px; text-align: left; vertical-align: top; }
13	    th { background-color: #f2f2f2; }
14	    pre { background: #f7f7f7; padding: 10px; border: 1px solid #ddd; overflow-x: auto; font-family: Consolas, monospace; font-size: 12.5px; }
15	    code { background: #eee; padding: 1px 4px; font-family: Consolas, monospace; font-size: 12.5px; }
16	    .center { text-align: center; }
17	    .b45 { background: #8b1a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
18	    .b4  { background: #b4531a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
19	    .b3  { background: #7a6a1a; color:#fff; padding:1px 8px; border-radius:9px; font-size:12px; font-weight:bold; }
20	    .note { background: #fff8e1; border-left: 4px solid #d4a017; padding: 10px 14px; margin: 12px 0; }
21	    .kpi { background: #eef4fb; border-left: 4px solid #2b5f8a; padding: 10px 14px; margin: 12px 0; }
22	    .stop { background: #fdecec; border-left: 4px solid #a33; padding: 10px 14px; margin: 12px 0; }
23	    .ok { background: #eaf5ea; border-left: 4px solid #2a7; padding: 10px 14px; margin: 12px 0; }
24	    ul, ol { margin-top: 6px; } li { margin-bottom: 4px; }
25	</style>
26	</head>
27	<body>
28	<h1>ĐỀ TÀI LAB v4.2 — FIREWALL &amp; SECURITY-FIRST</h1>
29	<p class="center"><strong>
30	Perimeter nhiều vùng có HA thật, IPS inline, chính sách dạng mã nguồn,
31	dịch vụ được bảo vệ nhiều lớp — vận hành trên một máy host, điều khiển từ máy thứ hai qua Tailscale
32	</strong></p>
33	
34	<div class="kpi">
35	<strong>v4.2 = 115.5 giờ, 12 VM (tất cả trên máy Hùng), Hùng 60h / Bảo 55.5h, lịch 14 ngày, chi phí phần cứng 0 đồng.</strong>
36	115.5h = <strong>82%</strong> quỹ 140 giờ (2 người × 10 ngày × 7 giờ) → còn 24.5 giờ đệm.
37	Độ khó trung bình <strong>≈ 4.35/5</strong>, cụm tường lửa–an ninh đạt <strong>4.5–4.8</strong>.
38	<br><br>
39	<strong>Thay đổi so với v4.1:</strong> bỏ toàn bộ dây cáp và USB-Ethernet adapter. Hai laptop nối nhau qua
40	<strong>Tailscale</strong>; máy Bảo làm việc từ xa bằng <code>ProxyJump</code> + port-forward —
41	<em>không</em> advertise route, <em>không</em> bật IP forwarding trên Windows. Được: GĐ0 giảm 12h xuống 8.5h,
42	toàn bộ lớp lỗi ghép nối giữa 2 máy biến mất, đường quản trị không còn chạm vào chính sách perimeter.
43	Mất: <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> nằm trong máy Hùng nên
44	attack validation giảm 4.6 xuống 4.2, NFR-13 chỉ còn đúng theo nghĩa phân tách vùng, và tiến độ của Bảo
45	phụ thuộc việc máy Hùng có bật hay không.
46	<br><br>
47	<strong>Bảy điều bắt buộc lưu ý khi dùng Tailscale nằm ở mục 2.4.</strong> Hai điều dễ chết người nhất:
48	mặc định Tailscale <em>hết hạn key sau 180 ngày</em>, và đừng cố <code>--advertise-routes</code> + IP forwarding trên Windows.
49	<br><br>
50	So với v3: chiều sâu dịch vụ bị giảm có chủ đích (bỏ drain/reload 0 lỗi, bỏ Redis session, bỏ rolling deploy,
51	bỏ auto-failover DB phức tạp) để dồn ngân sách vào 4 thứ: <em>perimeter HA, IPS inline, policy-as-code, kiểm chứng tấn công</em>.
52	</div>
53	
54	<h2>1. Thay đổi so với v3</h2>
55	<table>
56	    <tr><th>Chủ đề</th><th>v3</th><th>v4</th><th>Lý do</th></tr>
57	    <tr><td>Thiết bị biên</td><td>1× Debian + nftables</td><td><strong>2× OPNsense, CARP + pfsync + cfgsync</strong>, 5 vùng</td>
58	        <td>Đánh mạnh tường lửa thì phải có thiết bị biên thật, có HA, có state sync</td></tr>
59	    <tr><td>IPS</td><td>Suricata pcap / alert</td><td><strong>Suricata inline NFQUEUE (blocking)</strong> + test fail-open</td>
60	        <td>Chặn thật ở perimeter, không chỉ phát hiện</td></tr>
61	    <tr><td>Chính sách</td><td>File nftables trong Git</td><td><strong>YAML khai báo → render qua API OPNsense → apply không gián đoạn</strong></td>
62	        <td>Điểm khó nhất và cũng là điểm ăn tiền nhất của phần firewall</td></tr>
63	    <tr><td>Rate limit</td><td>Ở HAProxy (stick-table)</td><td><strong>Dịch chuyển xuống firewall</strong> (max states / alias + policy)</td>
64	        <td>Đúng chủ đề hơn: chống flood là việc của perimeter</td></tr>
65	    <tr><td>Góc nhìn tấn công</td><td>Client trong cùng host</td><td><strong>Attacker + sensor trên vmnet WAN riêng</strong> (v4.2: không còn ở máy thứ 2)</td>
66	        <td>Firewall chỉ có ý nghĩa khi bị đánh từ ngoài; sensor cho bằng chứng độc lập</td></tr>
67	    <tr><td>Hypervisor</td><td>VirtualBox + unicast hack</td><td><strong>VMware Workstation Pro</strong> (miễn phí cá nhân)</td>
68	        <td>CARP/pfsync dùng multicast — vmnet của VMware xử lý được, VirtualBox thì không ổn định</td></tr>
69	    <tr><td>HAProxy</td><td>8 tính năng, 15.5h</td><td>4 tính năng, 7h (TLS, mTLS, healthcheck, VIP)</td>
70	        <td>Nhượng giờ cho firewall</td></tr>
71	    <tr><td>DB</td><td>repmgr automatic failover</td><td>Streaming + <strong>promote có script + DB VIP</strong>, giữ PITR</td>
72	        <td>Giảm 3h, độ khó 4.5→4.2, vẫn chứng minh RPO=0</td></tr>
73	    <tr><td>Session</td><td>Redis + sticky cookie</td><td>Session trong DB, không sticky</td>
74	        <td>Giảm 2h; khai báo thẳng là trade-off trong báo cáo</td></tr>
75	</table>
76	
77	<h2>2. Hạ tầng: một máy host + Tailscale control plane</h2>
78	<table>
79	    <tr><th></th><th>Máy HÙNG — i5-12500H, 32 GB</th><th>Máy BẢO — i7-11800H, 16 GB</th></tr>
80	    <tr><td>Vai trò</td><td><strong>Toàn bộ lab</strong>: 12 VM, mọi vùng mạng</td>
81	        <td><strong>Control + Red plane từ xa</strong>: Ansible, Git/CI, Tailscale, trình duyệt (Grafana/GUI), WSL2</td></tr>
82	    <tr><td>VM</td>
83	        <td>opns1, opns2, lb1, lb2, web1, web2, pg1, pg2, obs, ca, attacker, sensor</td>
84	        <td><strong>0 VM</strong></td></tr>
85	    <tr><td>Ram</td>
86	        <td>2 + 2 + 0.5 + 0.5 + 1 + 1 + 1.5 + 1.5 + 2.5 + 0.5 + 2 + 1.5 = <strong>17 GB</strong> khi bật đủ;<br>
87	            steady state ~13.5 GB (attacker + sensor chỉ bật khi test)</td>
88	        <td>~2 GB cho WSL2 + Tailscale + trình duyệt</td></tr>
89	    <tr><td>Phần mềm cần cài</td><td>VMware Workstation Pro, OpenSSH Server, Tailscale</td><td>Tailscale, WSL2 + Ansible, Git</td></tr>
90	    <tr><td>Chi phí thêm</td><td colspan="2"><strong>0 đồng</strong> — không cáp, không USB-Ethernet adapter, không switch</td></tr>
91	</table>
92	
93	<h3>2.1 Bố trí vmnet (không còn bridged)</h3>
94	<pre>
95	MÁY HÙNG — 6 vmnet, TẤT CẢ là private/host-only trong host, không cái nào ra mạng vật lý:
96	
97	  vmnet-wan      10.0.0.0/24     : opns1 eth0 .1, opns2 eth0 .2, CARP VIP .100,
98	                                  attacker .20, sensor .21        ← "Internet" giả lập
99	  vmnet-sync     192.168.50.0/24 : opns1 ↔ opns2 (pfsync + cfgsync)
100	  vmnet-dmzfront 192.168.20.0/24 : opns eth1, lb1 .10, lb2 .11, Keepalived VIP .100
101	  vmnet-dmzapp   192.168.21.0/24 : opns eth2, web1 .21, web2 .22
102	  vmnet-trusted  192.168.30.0/24 : opns eth3, pg1 .11, pg2 .12, DB VIP .100
103	  vmnet-mgmt     192.168.99.0/24 : opns eth4, GUI VIP .100, obs .30, ca .31
104	
105	MÁY BẢO — không có vmnet nào tham gia lab:
106	  Tailscale 100.64.x.x  ──ssh──►  host Windows của Hùng (100.64.x.x)
107	                                    │ host có adapter trên MỖI vmnet ở trên
108	                                    └─► tới được mọi VM mà không cần route
109	</pre>
110	<div class="kpi">
111	<strong>Điểm làm cho phương án này chạy được:</strong> ProxyJump không định tuyến gói tin — nó mở một kết nối TCP
112	<em>từ host của Hùng</em> tới VM đích. Vì host OS vốn đã nằm trên từng vmnet (adapter VMnet1/VMnet8 tương ứng),
113	nó tới được mọi VM mà không cần advertise route, không cần IP forwarding, không cần RRAS. Đây là lý do bỏ được cáp
114	mà không phải đánh đổi cấu hình lab.
115	</div>
116	
117	<h3>2.2 Quyền truy cập từ máy Bảo</h3>
118	<pre>
119	# Liệt kê VM đang chạy và bật một VM từ xa
120	ssh hung@100.64.x.x '"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list'
121	ssh hung@100.64.x.x '"...\vmrun.exe" start "D:\lab\lb1\lb1.vmx" nogui'
122	
123	# Vào VM bất kỳ — dùng host làm jump hop
124	ssh -J hung@100.64.x.x ops@192.168.20.10          # lb1
125	ssh -J hung@100.64.x.x ops@192.168.30.11          # pg1
126	
127	# ansible.cfg — một dòng cho toàn bộ playbook
128	[ssh_connection]
129	ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ProxyJump=hung@100.64.x.x
130	
131	# Giao diện đồ hoạ: port-forward, không cần route
132	ssh -L 3000:192.168.99.30:3000 hung@100.64.x.x    # Grafana   → http://localhost:3000
133	ssh -L 9090:192.168.99.30:9090 hung@100.64.x.x    # Prometheus
134	ssh -L 8443:192.168.99.100:443  hung@100.64.x.x   # GUI OPNsense (CARP VIP vùng MGMT)
135	ssh -L 8404:192.168.20.10:8404  hung@100.64.x.x   # HAProxy stats
136	</pre>
137	<p>
138	<strong>Bastion vẫn tồn tại trong lab</strong> (<code>obs</code>, 192.168.99.30, NIC MGMT). Bạn <em>không</em> đi qua nó để vào
139	lab nữa, nhưng nó vẫn là node mà POL-005 ("SSH chỉ từ MGMT") áp dụng, và vẫn là nơi chạy <code>repmgr witness</code> +
140	syslog receiver. Nhờ vậy ma trận chính sách không bị rỗng ở dòng SSH — nếu bỏ luôn bastion thì T-07 mất một nửa ý nghĩa.
141	</p>
142	
143	<h3>2.3 Thiết kế đã loại: vì sao trước đây cần cáp</h3>
144	<div class="stop">
145	Phiên bản v4.1 dùng 2 sợi cáp để <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> chạy trên máy Bảo.
146	Lý do phải dùng L2 thật: <strong>Tailscale không tạo broadcast domain chung giữa hai máy</strong> (mesh các <code>/32</code>),
147	nên VM trên máy Bảo không thể nằm cùng segment WAN với <code>opns1</code>.
148	<br><br>
149	Và đây là lý do <em>không được</em> nhân tiện đặt DMZ-FRONT lên cùng L2 với WAN — attacker đi vòng qua perimeter:
150	<pre>
151	ip route add 192.168.20.0/24 dev eth0
152	arping -I eth0 192.168.20.100          # lấy được MAC của VIP
153	curl -k --resolve lab:443:192.168.20.100 https://lab/    # KHÔNG đi qua firewall
154	</pre>
155	Giữ lại đoạn này trong báo cáo như một <em>rejected design</em>: nó giải thích vì sao DMZ thật phải là VLAN/L2 riêng,
156	và vì sao ta chọn "mọi thứ trong một host, các vùng là vmnet tách biệt" thay vì "hai máy nối cáp".
157	</div>
158	
159	<h3>2.4 Bảy điều bắt buộc lưu ý khi dùng Tailscale</h3>
160	<table>
161	    <tr><th>#</th><th>Lưu ý</th><th>Chi tiết / lệnh</th></tr>
162	    <tr><td>1</td><td><strong>Tắt hạn key</strong></td>
163	        <td>Mặc định Tailscale hết hạn key sau 180 ngày. Hai máy chạy từ trước kỳ học → <em>giữa kỳ bị đá khỏi tailnet</em>,
164	        và thông báo rất khó đoán. <code>tailscale set --expiry=0</code> trên cả hai máy, ghi vào <code>docs/interfaces.md</code>.</td></tr>
165	    <tr><td>2</td><td><strong>Không advertise routes</strong></td>
166	        <td>Đừng chạy <code>--advertise-routes=192.168.20.0/24,...</code> và đừng cố bật IP forwarding trên Windows.
167	        ProxyJump + <code>-L</code> đã đủ mọi nhu cầu. Đây là hố thời gian lớn nhất của phương án này.</td></tr>
168	    <tr><td>3</td><td><strong>OpenSSH Server, không phải Tailscale SSH, cho vai jump</strong></td>
169	        <td>Tailscale SSH tiện để login nhưng hỗ trợ <code>-W</code>/ProxyJump không ổn định. Cài <code>sshd</code> Windows,
170	        StartupType Automatic, key-only.</td></tr>
171	    <tr><td>4</td><td><strong>Biết mình đang direct hay DERP</strong></td>
172	        <td>Cùng một LAN → kết nối trực tiếp, độ trễ &lt;1 ms, gần bằng cáp. Khác mạng → có thể đi qua DERP (rẽ qua Internet),
173	        latency nhảy. Trước mỗi phép đo timing: <code>tailscale status | grep &lt;bạn&gt;</code>, và ghi <code>direct</code>/<code>DERP</code> vào biên bản test.</td></tr>
174	    <tr><td>5</td><td><strong>Mất Internet = mất điều khiển từ xa</strong></td>
175	        <td>Không có fallback nào ngoài việc sang máy Hùng làm trực tiếp. Vì vậy: việc quan trọng luôn có lệnh thủ công tương đương,
176	        và không có việc nào chỉ chạy được từ máy Bảo.</td></tr>
177	    <tr><td>6</td><td><strong>Máy Hùng là điểm nghẽn tiến độ</strong></td>
178	        <td>Hùng tắt máy thì Bảo chỉ viết code/báo cáo. Quy ước: thông báo trước 1 ngày khi cần lab bật; phần việc của Bảo trong
179	        khung không có lab chuyển sang B04/B18 (policy YAML, báo cáo).</td></tr>
180	    <tr><td>7</td><td><strong>Đường quản trị không qua firewall — phải nói rõ</strong></td>
181	        <td>Đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter.
182	        Ghi thẳng vào báo cáo (B10) thay vì để giám khảo phát hiện; nếu không, nó trông như một lỗ hổng bạn không biết mình có.</td></tr>
183	</table>
184	
185	<h3>2.5 Cái được và cái mất so với phương án 2 cáp</h3>
186	<table>
187	    <tr><th></th><th>v4.1 — 2 cáp</th><th>v4.2 — Tailscale</th></tr>
188	    <tr><td>Chi phí phần cứng</td><td>2 USB-Ethernet adapter + 2 cáp (~500k)</td><td><strong>0đ</strong></td></tr>
189	    <tr><td>Giờ GĐ0</td><td>12h</td><td><strong>8.5h</strong></td></tr>
190	    <tr><td>Việc của Bảo chạy độc lập</td><td>~20h (obs/ca/attacker trên máy mình)</td><td>~10h (chỉ code + báo cáo; mọi test cần lab bật)</td></tr>
191	    <tr><td>Độ khó attack validation</td><td>4.6 (bằng chứng từ host vật lý khác)</td><td>4.2 (bằng chứng từ vmnet riêng, cùng host)</td></tr>
192	    <tr><td>NFR-13 giám sát ngoài vùng bảo vệ</td><td>Đúng nghĩa vật lý</td><td>Chỉ đúng nghĩa <em>logic</em> — obs ở vùng MGMT riêng, không node DMZ/TRUSTED nào ghi được</td></tr>
193	    <tr><td>Lỗi ghép nối giữa 2 máy</td><td>Có (adapter, driver, bridged Wi-Fi, client isolation)</td><td><strong>Không còn</strong></td></tr>
194	    <tr><td>Tổng giờ</td><td>120h</td><td><strong>115.5h</strong> (82% quỹ 140h)</td></tr>
195	</table>
196	
197	<h3>2.6 Quy ước vận hành</h3>
198	<ul>
199	    <li>Máy Hùng: Power plan High performance, <em>never sleep</em> khi cắm điện; <code>sshd</code> automatic; Tailscale autostart.</li>
200	    <li>Không ai tự <code>poweroff</code> VM của người kia. Lệnh tắt cả lab là lệnh chung, báo trước. Ghi rõ trong <code>CONTRIBUTING.md</code>.</li>
201	    <li>NTP: một source chung cho 12 VM + 2 host OS. PITR và đối chiếu log đa nguồn đều theo timestamp.</li>
202	    <li>Snapshot: <code>clean</code> (ngày 1), <code>green</code> (cuối mỗi ngày), <code>before-&lt;T-xx&gt;</code> (trước mỗi test phá),
203	        <code>IPS-off</code> (trước khi bật inline IPS).</li>
204	    <li>Việc nào cần bật attacker/sensor thì bật, xong thì tắt — tiết kiệm 3.5 GB RAM và tránh Suricata chạy nền làm nhiễu phép đo.</li>
205	</ul>
206	
207	<h2>3. Kiến trúc 5 vùng</h2>
208	<pre>
209	   MÁY BẢO (0 VM)                                MÁY HÙNG (12 VM, 6 vmnet riêng)
210	  Tailscale 100.64.x ──ssh / ProxyJump──► host Windows + WSL2 Ansible + Git/CI
211	  browser: Grafana, GUI OPNsense (qua ssh -L)
212	
213	   vmnet-wan  10.0.0.0/24 : attacker .20, sensor .21, opns1 .1 / opns2 .2,
214	                            CARP VIP .100  → DNAT 443 về LB VIP
215	   vmnet-sync 192.168.50.0/24 : opns1 ↔ opns2  (pfsync + cfgsync, không ra ngoài)
216	        ┌─────────┬──────────────┬────────────┬────────────────┐
217	   DMZ-FRONT   DMZ-APP        TRUSTED       MGMT
218	   192.168.20  192.168.21     192.168.30    192.168.99
219	   lb1 .10     web1 .21       pg1 .11       opns .1/.2, GUI VIP .100
220	   lb2 .11     web2 .22       pg2 .12       obs .30 (bastion + witness), ca .31
221	   VIP .100    (app+CRS)      DB VIP .100
222	   (Keepalived)               (repmgr + PITR)
223	        IPS inline: WAN + DMZ-FRONT + DMZ-APP
224	</pre>
225	<table>
226	    <tr><th>Vùng</th><th>Dải</th><th>Node</th><th>Nằm ở</th><th>Chính sách mặc định</th><th>IPS</th></tr>
227	    <tr><td>WAN</td><td>10.0.0.0/24</td><td>opns1/2 WAN, CARP .100, attacker .20, sensor .21</td><td>Máy Hùng (vmnet-wan)</td>
228	        <td>Chỉ DNAT 443 → LB VIP + SSH từ <code>ADMIN_SRC</code> → bastion; mọi inbound khác drop</td><td>Có (inline)</td></tr>
229	    <tr><td>DMZ-FRONT</td><td>192.168.20.0/24</td><td>lb1 .10, lb2 .11, VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
230	        <td>lb chỉ được gọi web:8443 và NTP/MGMT theo whitelist</td><td>Có (inline)</td></tr>
231	    <tr><td>DMZ-APP</td><td>192.168.21.0/24</td><td>web1 .21, web2 .22</td><td>Máy Hùng (vmnet riêng)</td>
232	        <td>Chỉ được gọi TRUSTED:5432; <strong>cấm egress ra WAN</strong></td><td>Có (inline)</td></tr>
233	    <tr><td>TRUSTED</td><td>192.168.30.0/24</td><td>pg1 .11, pg2 .12, DB VIP .100</td><td>Máy Hùng (vmnet riêng)</td>
234	        <td>Chỉ nhận từ alias <code>APP_NODES</code>; cấm ra WAN</td><td>Không (giữ hiệu năng)</td></tr>
235	    <tr><td>MGMT</td><td>192.168.99.0/24</td><td>opns .1/.2, GUI VIP .100, obs .30, ca .31</td><td>Máy Hùng (vmnet-mgmt)</td>
236	        <td>GUI + SSH chỉ từ MGMT/bastion; obs được phép scrape các vùng</td><td>Không</td></tr>
237	</table>
238	<div class="note">
239	<strong>Hai segment xuyên máy là WAN và MGMT — và chỉ hai cái đó.</strong> Nguyên tắc: một segment chỉ được trải
240	qua 2 máy khi nó <em>không</em> chứa node nào mà attacker có thể lợi dụng để đi vòng qua perimeter. WAN là vùng
241	không tin cậy (mọi thứ đi qua nó đều bị kiểm), MGMT là vùng quản trị có kiểm soát (bastion + <code>ADMIN_SRC</code>).
242	DMZ-FRONT/DMZ-APP/TRUSTED bắt buộc ở lại trong một host — xem 2.4.
243	</div>
244	
245	<h2>4. Ràng buộc phi chức năng (14 điều, firewall-first)</h2>
246	<table>
247	    <tr><th>Mã</th><th>Ràng buộc</th><th>Ngưỡng phải đạt</th></tr>
248	    <tr><td>NFR-01</td><td>CARP failover</td><td>Đổi master ≤ 5 s; <strong>session TCP đang mở không đứt</strong> (pfsync hoạt động) — đo bằng <code>iperf3</code> + <code>ssh</code> đang chạy</td></tr>
249	    <tr><td>NFR-02</td><td>Áp dụng chính sách dưới tải</td><td>Thêm/sửa rule qua API: 0 gián đoạn, 0 lỗi 5xx, không cắt state đang có</td></tr>
250	    <tr><td>NFR-03</td><td>Default-deny tuyệt đối</td><td>Mọi permit phải tham chiếu <strong>alias</strong>, không hardcode IP đơn; 24 combo (zone,dst,port) kiểm tự động, khớp 100%</td></tr>
251	    <tr><td>NFR-04</td><td>IPS fail-closed</td><td>Khi Suricata/NFQUEUE chết, traffic <strong>không</strong> được flow-through im lặng; phải có alert + test chứng minh hành vi đã chọn</td></tr>
252	    <tr><td>NFR-05</td><td>Bằng chứng cho mọi rule</td><td>Mỗi rule có <code>POLICY-ID</code> + counter; báo cáo nêu được rule nào đã được kích hoạt bởi kịch bản nào</td></tr>
253	    <tr><td>NFR-06</td><td>Chống flood ở perimeter</td><td>State table limit / max src conn: SYN flood 50k pkt/s không làm sập dịch vụ, VIP vẫn nổi</td></tr>
254	    <tr><td>NFR-07</td><td>Không có egress</td><td>DMZ-APP và TRUSTED không tự ra WAN được (chặn C2/exfil); kiểm bằng reverse shell mô phỏng</td></tr>
255	    <tr><td>NFR-08</td><td>Log tập trung + tương quan</td><td>Firewall + IPS + WAF + app về obs, giữ ≥ 7 ngày; tái hiện được 1 chuỗi tấn công hoàn chỉnh bằng log</td></tr>
256	    <tr><td>NFR-09</td><td>Bảo mật truyền thông</td><td>mTLS LB→web; GUI/Giám sát chỉ qua TLS; không plaintext credential</td></tr>
257	    <tr><td>NFR-10</td><td>Khôi phục dữ liệu</td><td>PITR tới timestamp chỉ định, verify bản ghi; RPO = 0 khi mất DB primary</td></tr>
258	    <tr><td>NFR-11</td><td>Hardening thiết bị biên</td><td>Tắt service thừa, GUI TLS + khoá root shell, NTP, backup config có mã hoá, bogon + private-network + anti-spoof bật</td></tr>
259	    <tr><td>NFR-12</td><td>IaC</td><td>Toàn bộ chính sách + config dịch vụ là mã nguồn; rebuild ≤ 30 phút; <code>make check</code> xanh; drift = 0</td></tr>
260	    <tr><td>NFR-13</td><td>Mặt phẳng giám sát ngoài vùng bảo vệ</td><td><code>obs</code>, <code>ca</code>, <code>sensor</code> chạy trên máy khác và không có node nào bị compromise xoá/sửa được bằng chứng về chính nó; kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert</td></tr>
261	    <tr><td>NFR-14</td><td>Không có đường vòng L2</td><td>Không tồn tại segment nào vừa chứa attacker vừa chứa node dịch vụ được bảo vệ; chứng minh bằng <code>arping</code> thất bại từ attacker tới DMZ-FRONT</td></tr>
262	</table>
263	
264	<h2>5. Độ khó theo hạng mục</h2>
265	<table>
266	    <tr><th>Hạng mục</th><th>Độ khó</th><th>Vì sao ở mức đó</th></tr>
267	    <tr><td>OPNsense ×2 + CARP + pfsync + cfgsync</td><td><span class="b45">4.8</span></td><td>HA tầng 2 trên 5 vùng; pfsync giữ state; cfgsync phải không ghi đè tay; failover đo bằng session đang mở</td></tr>
268	    <tr><td>Policy-as-code (YAML → API → apply)</td><td><span class="b45">4.7</span></td><td>Thiết kế mô hình alias/zone + render + áp dụng không gián đoạn + validate 24 combo</td></tr>
269	    <tr><td>Suricata inline IPS + fail-closed</td><td><span class="b45">4.6</span></td><td>NFQUEUE blocking thật, tuning rule, và trả lời câu hỏi "IPS chết thì hệ thống mở hay đóng"</td></tr>
270	    <tr><td>Attack validation + sensor-side evidence</td><td><span class="b45">4.6</span></td><td>Đánh từ ngoài, đối chiếu log phòng thủ với bằng chứng tấn công, map MITRE</td></tr>
271	    <tr><td>Perimeter anti-flood (state limit)</td><td><span class="b45">4.5</span></td><td>Phải đo được state table, không làm sập lab, và giải thích giới hạn</td></tr>
272	    <tr><td>pgBackRest PITR</td><td><span class="b45">4.5</span></td><td>WAL archive + restore theo timestamp + verify dữ liệu</td></tr>
273	    <tr><td>Log correlation + alerting</td><td><span class="b4">4.4</span></td><td>4 nguồn log khác định dạng, tương quan theo thời gian + IP</td></tr>
274	    <tr><td>IaC + CI + rebuild</td><td><span class="b4">4.4</span></td><td>Idempotent trên cả thiết bị biên, drift detection</td></tr>
275	    <tr><td>DB failover + fencing + DB VIP</td><td><span class="b4">4.2</span></td><td>Promote có script, node cũ bị chặn không ghi được</td></tr>
276	    <tr><td>HAProxy + Keepalived VIP</td><td><span class="b4">4.2</span></td><td>TLS, mTLS, health check, VIP multicast</td></tr>
277	    <tr><td>WAF CRS blocking</td><td><span class="b4">4.2</span></td><td>Blocking + ParanoiaLevel 2 + đo false positive</td></tr>
278	    <tr><td>PKI / mTLS</td><td><span class="b4">4.0</span></td><td>CA nội bộ, cert server+client, rotation cơ bản</td></tr>
279	    <tr><td>Web tier + app</td><td><span class="b3">3.6</span></td><td>Đã giản lược (không Redis/rolling deploy) — đây là phần chủ động nhường giờ</td></tr>
280	    <tr><td colspan="2"><strong>TB toàn đề tài</strong></td><td><strong>≈ 4.35 / 5</strong> — cụm firewall–an ninh TB 4.6</td></tr>
281	</table>
282	
283	<h2>6. Phạm vi chi tiết theo 6 cụm</h2>
284	
285	<h3>Cụm A — Nền tảng biên (Hùng)</h3>
286	<ul>
287	    <li>2× OPNsense, mỗi con 5 vNIC; VMXNET3; <code>sync</code> là vmnet host-only riêng cho pfsync + cfgsync (không để pfsync chạy trên WAN).</li>
288	    <li>CARP: vhid duy nhất per zone, 1 con MASTER (advskew thấp), <code>preempt</code> tắt để tránh flap khi demo; theo dõi <code>sysctl net.inet.carp.preempt</code>, <code>ifconfig carp</code>.</li>
289	    <li><strong>pfsync state sync</strong>: bật sync trên mọi interface, kiểm bằng session dài (iperf3/ssh) sống sót qua failover.</li>
290	    <li><strong>cfgsync</strong>: tài khoản sync chỉ có quyền tối thiểu; test sửa tay trên backup → master không bị ghi đè im lặng, và ngược lại phải có cảnh báo drift.</li>
291	    <li>Hardening: GUI HTTPS với cert nội bộ, tắt HTTP, vô hiệu service không dùng, <code>Allow OPT1..</code> tắt, anti-spoofing bật, bogon + private networks, NTP từ MGMT, định kỳ backup <code>config.xml</code> có mã hoá.</li>
292	    <li>Chống flood: <code>states</code> limit, <code>max-src-conn</code>, <code>syncookies</code> (kiểm bằng hping3 từ attacker, ghi lại số state và ảnh hưởng tới VIP).</li>
293	</ul>
294	
295	<h3>Cụm B — Chính sách dạng mã nguồn (Bảo)</h3>
296	<ul>
297	    <li>Mô hình khai báo trong Git: <code>zones</code>, <code>aliases</code> (group objects: <code>APP_NODES</code>, <code>DB_VIP</code>, <code>MGMT_ALLOWED</code>), <code>services</code>, <code>rules[]</code> với <code>id: POL-xxx</code>, <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>.</li>
298	    <li>Renderer Ansible → gọi API OPNsense (alias add/set, rule_filter add/set, <code>apply</code> + <code>filter reload</code>) — reload không cắt state, đó là cơ sở của NFR-02. <em>Cần verify tên endpoint trên đúng phiên bản bạn cài; tài liệu API thay đổi theo release.</em></li>
299	    <li>Idempotency: chạy 2 lần ra cùng một rule set; xoá 1 rule trong YAML → rule biến mất trên thiết bị (không phải cộng dồn).</li>
300	    <li><strong>Policy validator</strong>: quét 24 combo (zone nguồn, đích, port) từ attacker/sensor/web/db, so với YAML, xuất CSV; đồng thời đọc counter của từng rule để chứng minh rule đã thực sự được đi qua.</li>
301	    <li>Drift check: <code>make drift</code> so trạng thái thiết bị với Git, khác biệt = fail CI.</li>
302	</ul>
303	
304	<h3>Cụm C — IPS, WAF và kiểm chứng tấn công</h3>
305	<ul>
306	    <li>Suricata inline trên WAN + DMZ-FRONT + DMZ-APP (OPNsense plugin, chế độ NFQUEUE, blocking), ruleset: emerging-threats + rule tự viết cho hành vi của lab.</li>
307	    <li>Test <strong>fail-closed</strong>: dừng dịch vụ Suricata khi đang có kết nối → xác nhận traffic bị chặn (không phải âm thầm flow-through) và có alert; ghi rõ lựa chọn thiết kế.</li>
308	    <li>CRS blocking trên Apache (mod_security2), ParanoiaLevel 2, file overrides trong Git kèm <code>Reason:</code>.</li>
309	    <li>Bộ tấn công từ <code>attacker</code> — 4 lớp trong harness (B14): (1) nmap/scan → IPS alert; (2) 30 payload web (SQLi/XSS/traversal) → WAF 403 + IPS; (3) SSH brute force → Fail2Ban + alias ban; (4) egress attempt từ web ra WAN → bị chặn. Lớp thứ 5 (SYN flood → state limit) thuộc H10 vì nó là việc của thiết bị biên.</li>
310	    <li><strong>Sensor</strong> (VM riêng trên vmnet-wan) chạy tcpdump + Zeek độc lập: với mỗi tấn công, đối chiếu "tôi đã gửi gì" và "hệ thống phòng thủ ghi nhận gì"; bảng lệch nhau là nội dung báo cáo có giá trị nhất.</li>
311	    <li>Map MITRE ATT&amp;CK: T1046 (scan), T1190 (exploit public app), T1110 (brute force), T1048/T1071 (egress/C2), T1562.110 (impair defenses — chính là test fail-closed).</li>
312	</ul>
313	
314	<h3>Cụm D — Tầng dịch vụ được bảo vệ (Bảo)</h3>
315	<ul>
316	    <li>HAProxy ×2: TLS termination, mTLS xuống web, health check <code>/healthz</code>, stats bind MGMT.</li>
317	    <li>Keepalived VIP <code>192.168.20.100</code>: multicast VRRP (VMware chạy được), 1 MASTER/1 BACKUP, <code>track_script</code> kiểm HAProxy.</li>
318	    <li>App 4 endpoint: <code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code> (ghi DB), <code>/session</code>; session lưu trong PostgreSQL (chứng minh app stateless mà không cần Redis).</li>
319	    <li>Web chỉ nhận kết nối có client cert; không truy cập Internet.</li>
320	</ul>
321	
322	<h3>Cụm E — Tầng dữ liệu + khôi phục (Hùng)</h3>
323	<ul>
324	    <li>PostgreSQL 16 ×2, streaming replication, <code>synchronous_commit = on</code>, <code>hostssl</code> + scram.</li>
325	    <li>Failover bằng script <code>promote.sh</code>: di chuyển <code>DB_VIP 192.168.30.100</code> sang standby + đẩy alias firewall cập nhật + <strong>fence</strong> node cũ (stop + rule chặn 5432 từ nó).</li>
326	    <li>App không đổi connection string (luôn trỏ DB_VIP) — đây là điểm khác biệt so với v3 và là thứ phải chứng minh được.</li>
327	    <li>pgBackRest: full + incremental + WAL archive lên obs (repo NFS/ssh), <strong>diễn tập PITR</strong> tới timestamp và verify 3 bản ghi mốc.</li>
328	</ul>
329	
330	<h3>Cụm F — Bằng chứng, quan sát, tự động hoá (Bảo)</h3>
331	<ul>
332	    <li>Remote syslog 3 nguồn từ OPNsense + web + db → obs (rsyslog → Loki); 3 dashboard Grafana với 4 panel chính: policy hit, IPS block, WAF block, state table.</li>
333	    <li><strong>Mặt phẳng giám sát nằm ngoài vùng bảo vệ</strong> (NFR-13): <code>obs</code>, <code>ca</code>, <code>sensor</code> nằm ở vùng MGMT/WAN riêng,
334	        nên không node nào trong vùng bị bảo vệ có khả năng xoá hoặc sửa bằng chứng về chính nó. Kiểm bằng cách tắt <code>opns1</code> và vẫn phải thấy alert.</li>
335	    <li>Prometheus: node_exporter, haproxy export, postgres_exporter; 6 alert: mất master CARP, IPS xuống, rule counter bất thường, 5xx &gt; 1%, DB leader đổi, PITR backup &gt; 24h chưa chạy.</li>
336	    <li>Ansible + <code>make check</code> (lint + <code>haproxy -c</code> + <code>apachectl configtest</code> + <code>suricata -T</code> + gitleaks) + <code>make drift</code>.</li>
337	    <li><code>run_matrix.sh</code> sinh CSV theo schema: <code>scenario,ts,host,detect_s,rto_s,req_total,err_5xx,err_conn,pass</code>.</li>
338	</ul>
339	
340	<h2>7. Cấu hình tham chiếu</h2>
341	
342	<h3>7.1 Mô hình chính sách khai báo (file nguồn duy nhất)</h3>
343	<pre>
344	# policy/zones.yml
345	zones:
346	  wan:       { net: 10.0.0.0/24,        iface: wan }
347	  dmz_front: { net: 192.168.20.0/24,    iface: opt1 }
348	  dmz_app:   { net: 192.168.21.0/24,    iface: opt2 }
349	  trusted:   { net: 192.168.30.0/24,    iface: opt3 }
350	  mgmt:      { net: 192.168.99.0/24,    iface: opt4 }
351	
352	aliases:
353	  LB_VIP:    { type: host,   items: [192.168.20.100] }
354	  APP_NODES: { type: network, items: [192.168.21.21/32, 192.168.21.22/32] }
355	  DB_VIP:    { type: host,   items: [192.168.30.100] }
356	  MGMT_ONLY: { type: network, items: [192.168.99.0/24] }
357	
358	rules:
359	  - id: POL-001
360	    desc: "Public HTTPS vào LB VIP"
361	    zone: wan -> dmz_front
362	    proto: tcp, dst: LB_VIP, dport: 443
363	    action: pass, log: true, test: T-07
364	    nat: { type: static-port-forward, to: 192.168.20.100:443 }
365	
366	  - id: POL-002
367	    desc: "Web truy cập DB, chỉ từ alias APP_NODES"
368	    zone: dmz_app -> trusted
369	    proto: tcp, src: APP_NODES, dst: DB_VIP, dport: 5432
370	    action: pass, log: true, test: T-07
371	
372	  - id: POL-003
373	    desc: "Cấm WAN vào DB (kiểm chứng deny)"
374	    zone: wan -> trusted
375	    proto: any, dst: any, dport: [5432, 3306]
376	    action: block, log: true, test: T-07
377	
378	  - id: POL-004
379	    desc: "Cấm egress từ DMZ-APP và TRUSTED ra WAN"
380	    zone: [dmz_app, trusted] -> wan
381	    proto: any, action: block, log: true, test: T-13
382	
383	  - id: POL-005
384	    desc: "SSH chỉ từ MGMT"
385	    zone: any -> any, proto: tcp, dport: 22
386	    src: MGMT_ONLY, action: pass, log: true
387	    else: { action: reject, test: T-11 }
388	    options: { max-src-conn: 10, max-src-conn-rate: "20/5", overload: { table: "ban_table", clear: 3600 } }
389	</pre>
390	
391	<h3>7.2 Renderer + apply không gián đoạn (Ansible)</h3>
392	<pre>
393	# roles/opnsense_policy/tasks/main.yml  (ý đồ, không phải code chạy ngay)
394	- name: Đồng bộ alias
395	  uri:
396	    url: "https://{{ opns_host }}/api/firewall/alias/{{ item.action }}{{ item.uuid or '' }}"
397	    method: POST
398	    user: "{{ api_key }}"; password: "{{ api_secret }}"
399	    body_format: json
400	    body: { alias: { name: "{{ item.name }}", type: "{{ item.type }}", content: "{{ item.items | join(' ') }}", descr: "{{ item.id }}" } }

#### Thinking

**Planning HTML inspection with grep**

#### Tool: Grep

**Input:**

```json
{
  "pattern": "<h2>|<h3>|T-[0-9]+|GĐ[0-9]|Phase|phase",
  "path": "D:\\Lab\\ha-lb-security-lab.html",
  "glob": "*.html",
  "output_mode": "content",
  "-B": 0,
  "-A": 2,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": false,
  "-o": false,
  "type": "",
  "head_limit": 300,
  "offset": 0,
  "multiline": false
}
```

**Response:**

41:<em>không</em> advertise route, <em>không</em> bật IP forwarding trên Windows. Được: GĐ0 giảm 12h xuống 8.5h,
--
54:<h2>1. Thay đổi so với v3</h2>
--
77:<h2>2. Hạ tầng: một máy host + Tailscale control plane</h2>
--
93:<h3>2.1 Bố trí vmnet (không còn bridged)</h3>
--
117:<h3>2.2 Quyền truy cập từ máy Bảo</h3>
--
140:syslog receiver. Nhờ vậy ma trận chính sách không bị rỗng ở dòng SSH — nếu bỏ luôn bastion thì T-07 mất một nửa ý nghĩa.
--
143:<h3>2.3 Thiết kế đã loại: vì sao trước đây cần cáp</h3>
--
159:<h3>2.4 Bảy điều bắt buộc lưu ý khi dùng Tailscale</h3>
--
185:<h3>2.5 Cái được và cái mất so với phương án 2 cáp</h3>
--
189:    <tr><td>Giờ GĐ0</td><td>12h</td><td><strong>8.5h</strong></td></tr>
--
197:<h3>2.6 Quy ước vận hành</h3>
--
207:<h2>3. Kiến trúc 5 vùng</h2>
--
245:<h2>4. Ràng buộc phi chức năng (14 điều, firewall-first)</h2>
--
264:<h2>5. Độ khó theo hạng mục</h2>
--
283:<h2>6. Phạm vi chi tiết theo 6 cụm</h2>
--
285:<h3>Cụm A — Nền tảng biên (Hùng)</h3>
--
295:<h3>Cụm B — Chính sách dạng mã nguồn (Bảo)</h3>
--
304:<h3>Cụm C — IPS, WAF và kiểm chứng tấn công</h3>
--
314:<h3>Cụm D — Tầng dịch vụ được bảo vệ (Bảo)</h3>
--
322:<h3>Cụm E — Tầng dữ liệu + khôi phục (Hùng)</h3>
--
330:<h3>Cụm F — Bằng chứng, quan sát, tự động hoá (Bảo)</h3>
--
340:<h2>7. Cấu hình tham chiếu</h2>
--
342:<h3>7.1 Mô hình chính sách khai báo (file nguồn duy nhất)</h3>
--
363:    action: pass, log: true, test: T-07
--
370:    action: pass, log: true, test: T-07
--
376:    action: block, log: true, test: T-07
--
381:    proto: any, action: block, log: true, test: T-13
--
387:    else: { action: reject, test: T-11 }
--
391:<h3>7.2 Renderer + apply không gián đoạn (Ansible)</h3>
--
421:<h3>7.3 CARP + pfsync + cfgsync (trên thiết bị)</h3>
--
436:<h3>7.4 Suricata inline + test fail-closed</h3>
--
446:<h3>7.5 HAProxy + Keepalived (đã giản lược)</h3>
--
471:<h3>7.6 DB promote + fencing + PITR</h3>
--
483:<h2>8. Ma trận kiểm thử — 14 kịch bản</h2>
--
486:    <tr><td>T-01</td><td>Phân phối tải qua VIP</td><td>attacker</td><td>30 req/s, cả 2 web ≥ 40% request</td></tr>
487:    <tr><td>T-02</td><td>Chết 1 web node</td><td>máy Hùng</td><td>Phát hiện ≤ 6 s, 0 lỗi 5xx, phiên (DB) còn</td></tr>
488:    <tr><td>T-03</td><td>Keepalived VIP đổi chủ</td><td>máy Hùng</td><td>≤ 10 s, mất ≤ 0.5% request đang truyền</td></tr>
489:    <tr><td>T-04</td><td><strong>CARP failover giữ session</strong></td><td>attacker</td><td>iperf3 + ssh đang chạy <em>không đứt</em>, đổi master ≤ 5 s</td></tr>
490:    <tr><td>T-05</td><td>Cắt đường pfsync/heartbeat</td><td>máy Hùng</td><td>Không có 2 MASTER; hành vi được giải thích + có alert</td></tr>
491:    <tr><td>T-06</td><td>cfgsync drift</td><td>cả hai</td><td>Sửa tay trên backup → master không bị ghi đè im lặng; <code>make drift</code> báo đúng</td></tr>
492:    <tr><td>T-07</td><td><strong>Ma trận chính sách 24 combo</strong></td><td>attacker/sensor/web/db</td><td>Khớp YAML 100%; mỗi rule có counter &gt; 0; WAN→DB và SSH phải bị chặn</td></tr>
493:    <tr><td>T-08</td><td><strong>Áp dụng policy dưới tải</strong></td><td>attacker</td><td>Thêm rule + reload: 0 gián đoạn, 0 lỗi 5xx, state giữ nguyên</td></tr>
494:    <tr><td>T-09</td><td>IPS chặn scan + payload</td><td>attacker</td><td>nmap bị phát hiện; ≥ 90% payload bị chặn ở IPS hoặc WAF</td></tr>
495:    <tr><td>T-10</td><td><strong>IPS fail-closed</strong></td><td>attacker</td><td>Suricata chết → hệ thống xử lý đúng lựa chọn đã công bố, có alert</td></tr>
496:    <tr><td>T-11</td><td>SSH brute force</td><td>attacker</td><td>Fail2Ban/overload table ban trong ≤ 5', unban đúng hạn, có log</td></tr>
497:    <tr><td>T-12</td><td>WAF false positive</td><td>attacker</td><td>15 request hợp lệ có nháy/JSON/unicode → 0 block sai</td></tr>
498:    <tr><td>T-13</td><td>DB failover + RPO + PITR</td><td>máy Hùng</td><td>Leader mới ≤ 40 s, commit cuối còn, restore tới timestamp verify 3 bản ghi</td></tr>
499:    <tr><td>T-14</td><td>Cấm egress / chống flood</td><td>web, attacker</td><td>Reverse shell từ web ra WAN thất bại; SYN flood 50k pkt/s không sập VIP</td></tr>
--
502:<h2>9. PHÂN CÔNG CHI TIẾT THEO 7 GIAI ĐOẠN — 115.5 giờ</h2>
--
508:<h3>GĐ0 — Hạ tầng + Tailscale control plane (ngày 1–2) · 8.5h</h3>
--
538:<h3>GĐ1 — Perimeter cơ bản &amp; mô hình chính sách (ngày 2–4) · 12h</h3>
--
549:        cho đường bastion. Kèm schema validation + <code>yamllint</code>. Lập bảng 24 combo (zone, đích, port) làm nguồn chân lý cho T-07.</td>
--
555:        Đây là lần đầu "chính sách là mã nguồn" được chứng minh — làm ở ngày 4, không dồn sang GĐ2.</td></tr>
--
558:<h3>GĐ2 — CARP + renderer API + HAProxy (ngày 4–6) · 20h</h3>
--
564:        Test T-04 (iperf3 + ssh đang chạy phải sống sót), T-05 (cắt vmnet-sync → không có 2 MASTER),
565:        T-06 (sửa tay trên backup → master không bị ghi đè im lặng).</td>
566:        <td>8</td><td>T-04, T-05, T-06 pass kèm số liệu</td></tr>
--
572:        <td>6</td><td>T-08 pass: thêm rule lúc 30 req/s, 0 gián đoạn, state không giảm</td></tr>
--
583:<h3>GĐ3 — IPS inline + dịch vụ + DB nền (ngày 6–8) · 22h</h3>
--
595:        <td>4</td><td>T-07 pass 24/24; mọi rule được kiểm đều có counter &gt; 0</td></tr>
--
599:        <td>3</td><td>T-03 pass: VIP đổi chủ ≤ 10 s</td></tr>
--
603:        <td>5</td><td>T-01, T-02 pass; phiên còn sau khi chết 1 web node</td></tr>
604:    <tr><td colspan="5"><strong>Checkpoint 1 (hết ngày 8):</strong> T-01, T-02, T-03, T-04, T-07 pass.
605:        Nếu T-04 hoặc T-07 chưa đạt thì cắt phạm vi <em>ngay bây giờ</em>, không phải ngày 12.</td></tr>
--
608:<h3>GĐ4 — An ninh sâu + khôi phục (ngày 8–10) · 20.5h</h3>
--
614:        <td>5</td><td>T-13a: leader mới ≤ 40 s, commit cuối còn, node cũ không ghi được</td></tr>
--
618:        <td>4</td><td>T-12: 15 request hợp lệ → 0 block sai</td></tr>
--
622:        <td>2</td><td>T-10 pass + có đoạn văn thiết kế</td></tr>
--
625:        <td>2</td><td>T-14a: 50k pkt/s không làm sập VIP, có số liệu state table</td></tr>
--
641:    <tr><td colspan="5"><strong>Checkpoint 2 (hết ngày 10):</strong> T-09, T-10, T-11, T-12, T-13 pass.
642:        Nếu T-13 chưa đạt, chạy bảng cắt khẩn cấp ở mục 11 <em>trong ngày 10</em>.</td></tr>
--
645:<h3>GĐ5 — Kiểm chứng tấn công &amp; quan sát (ngày 10–12) · 16h</h3>
--
656:        <td>7</td><td>T-09, T-14 pass; bảng đối chiếu sensor-vs-defender hoàn chỉnh</td></tr>
--
660:        <td>5</td><td>T-13b pass + biên bản thời gian và dung lượng WAL</td></tr>
--
665:<h3>GĐ6 — Test, rebuild, báo cáo (ngày 12–14) · 16h</h3>
--
668:    <tr><td>H13</td><td><strong>Hùng</strong></td><td>Chạy lại 8 kịch bản phần biên: T-04, T-05, T-06, T-08, T-10, T-11, T-13, T-14a</td><td>3</td><td>8/8 pass, có CSV</td></tr>
669:    <tr><td>B15</td><td><strong>Bảo</strong></td><td>Chạy lại 6 kịch bản phần dịch vụ: T-01, T-02, T-03, T-07, T-09, T-12</td><td>3</td><td>6/6 pass</td></tr>
--
673:    <tr><td>H15</td><td><strong>Hùng</strong></td><td>Báo cáo phần perimeter/CARP/IPS/PITR + video demo 6 kịch bản (T-04, T-08, T-09, T-10, T-13, T-14)</td><td>2</td><td>Video + snapshot <code>green</code> cuối</td></tr>
--
676:<h3>Tổng kết phân công</h3>
--
679:    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
680:    <tr><td>GĐ1 Perimeter + mô hình</td><td>2–4</td><td>6</td><td>6</td><td>12</td><td>curl chạm dịch vụ giả; YAML được duyệt</td></tr>
681:    <tr><td>GĐ2 CARP + renderer + LB</td><td>4–6</td><td>14</td><td>6</td><td>20</td><td>T-04, T-05, T-06, T-08</td></tr>
682:    <tr><td>GĐ3 IPS + dịch vụ + DB nền</td><td>6–8</td><td>10</td><td>12</td><td>22</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-07</td></tr>
683:    <tr><td>GĐ4 An ninh sâu + khôi phục</td><td>8–10</td><td>15</td><td>5.5</td><td>20.5</td><td><strong>Checkpoint 2</strong>: T-09 tới T-13</td></tr>
684:    <tr><td>GĐ5 Kiểm chứng + quan sát</td><td>10–12</td><td>5</td><td>11</td><td>16</td><td>T-14 + PITR + alert thật</td></tr>
685:    <tr><td>GĐ6 Test + báo cáo</td><td>12–14</td><td>6.5</td><td>9.5</td><td>16</td><td>14/14 pass + video</td></tr>
--
689:<strong>Hai người cố tình không đối xứng.</strong> Hùng tập trung giờ ở GĐ2 + GĐ4 (29h) vì đó là CARP và an ninh sâu — phần cần hiểu thiết bị.
690:Bảo tập trung ở GĐ0 + GĐ3 + GĐ5 (28h) vì đó là control plane, validator và kiểm chứng tấn công — phần cần viết code và chạy script.
--
694:<h2>10. Lịch 14 ngày theo mã việc</h2>
--
702:    <tr><td>6</td><td>H03 cfgsync, H04 HAProxy TLS/mTLS</td><td>B06 renderer + apply dưới tải</td><td>T-04 pass (session sống sót), T-08 pass</td></tr>
703:    <tr><td>7</td><td>H04 HAProxy + H06 PostgreSQL streaming</td><td>B09 app + web ×2</td><td>T-01, T-02 pass</td></tr>
704:    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
705:    <tr><td>9</td><td>H07 promote/fencing, H08 CRS, H09 fail-closed</td><td>B10 tài liệu hoá out-of-band mgmt path, B11 step-ca</td><td>T-09, T-10, T-12 pass</td></tr>
706:    <tr><td>10</td><td>H10 state limit, H11 hardening, H12 PITR (bắt đầu)</td><td>B12 syslog → Loki</td><td><strong>Checkpoint 2</strong>: T-13, T-14 pass</td></tr>
--
718:<h2>11. Bảng cắt khẩn cấp (kích hoạt ở Checkpoint 1 hoặc 2)</h2>
--
732:<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
--
756:<h2>13. Sáu mươi phút đầu tiên — làm đủ rồi mới chia việc</h2>

#### Thinking

**Inspecting phases/cut table assumptions**

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 502,
  "limit": 260,
  "pages": ""
}
```

**Response:**

502	<h2>9. PHÂN CÔNG CHI TIẾT THEO 7 GIAI ĐOẠN — 115.5 giờ</h2>
503	<p>
504	Mỗi giai đoạn có <strong>mốc ghép</strong> (hai người cùng xác nhận) và <strong>điều kiện ra</strong>.
505	Mã việc: <code>H##</code> = Hùng, <code>B##</code> = Bảo. Thứ tự đã sắp xếp để không ai phải chờ ai quá một ngày.
506	</p>
507	
508	<h3>GĐ0 — Hạ tầng + Tailscale control plane (ngày 1–2) · 8.5h</h3>
509	<table>
510	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
511	    <tr><td>H01</td><td><strong>Hùng</strong></td>
512	        <td>VMware Workstation Pro. Tạo 12 VM (opns1/2, lb1/2, web1/2, pg1/2, obs, ca, attacker, sensor) từ linked clone
513	        template Debian 12 + OPNsense. Dựng 6 vmnet theo mục 2.1 — <strong>tất cả private, không cấu hình bridged nào</strong>.
514	        Thêm <code>vmnet-sync</code> host-only giữa 2 con opns. Snapshot <code>clean</code>, chrony một source.</td>
515	        <td>3.5</td><td>Mỗi VM đúng số NIC theo mục 3; <code>vmrun list</code> thấy 12; <code>date</code> khớp nhau</td></tr>
516	    <tr><td>B01</td><td><strong>Bảo</strong></td>
517	        <td>Cài Tailscale cả hai máy, cùng tailnet, <code>tailscale set --expiry=0</code> (mục 2.4 #1).
518	        Trên máy Hùng: cài + bật <code>sshd</code> (StartupType Automatic, key-only).
519	        Kiểm từ máy Bảo: <code>ssh hung@100.64.x</code>, rồi <code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào 1 VM bất kỳ.
520	        Ghi IP tailscale của nhau vào <code>docs/interfaces.md</code>.</td>
521	        <td>1.5</td><td>ProxyJump vào được VM — <strong>đây là điều kiện sống còn của cả phương án</strong></td></tr>
522	    <tr><td>B02</td><td><strong>Bảo</strong></td>
523	        <td>Cấu hình <code>attacker</code> (nmap, hping3, hydra, curl, hey, bộ payload) và <code>sensor</code>
524	        (tcpdump, Zeek, rsyslog forward, promiscuous mode trên NIC vmnet-wan) — hai VM này nằm trên máy Hùng nhưng
525	        do Bảo sở hữu và vận hành.</td>
526	        <td>2</td><td>attacker ping 10.0.0.1; sensor bắt được traffic giữa attacker và CARP VIP</td></tr>
527	    <tr><td>B03</td><td><strong>Bảo</strong></td>
528	        <td>Repo Git + <code>.gitignore</code> (<code>*.key</code>, <code>certs/issued/</code>, <code>secrets.yml</code>) + gitleaks.
529	        <code>Makefile</code> + <code>make check</code>. WSL2 + Ansible. <code>ansible.cfg</code> có <code>ProxyJump</code>,
530	        key SSH distribution cho 12 VM, inventory 6 nhóm vùng.</td>
531	        <td>1.5</td><td><code>ansible all -m ping</code> xanh đủ 12 VM; <code>make check</code> chạy được</td></tr>
532	    <tr><td colspan="5"><strong>Mốc ghép:</strong> hai người cùng chạy <code>scripts/verify_access.sh</code> — 3 phép kiểm:
533	        ProxyJump vào VM trong từng vùng (wan/dmzfront/dmzapp/trusted/mgmt), <code>vmrun start</code> từ xa, và
534	        <code>tailscale status</code> hiện <code>direct</code>. <strong>Bước ProxyJump trượt thì dừng ngay</strong> và bàn lại:
535	        hoặc chuyển sang mô hình ngồi chung một máy (giữ nguyên 14 kịch bản), hoặc quay lại phương án cáp. Không mò quá 60 phút.</td></tr>
536	</table>
537	
538	<h3>GĐ1 — Perimeter cơ bản &amp; mô hình chính sách (ngày 2–4) · 12h</h3>
539	<table>
540	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
541	    <tr><td>H02</td><td><strong>Hùng</strong></td>
542	        <td>OPNsense 5 vNIC, đặt <code>descr</code> đúng tên zone trong YAML. Alias/zone tạo tay để kiểm mô hình.
543	        DNAT 443 WAN → LB VIP. Routing 2 chiều + default gateway. GUI HTTPS với cert tạm. Chưa có LB thì test bằng
544	        <code>nc -lvnp 443</code> trên lb1.</td>
545	        <td>6</td><td><code>curl -k https://10.0.0.100</code> từ attacker chạm tới dịch vụ giả</td></tr>
546	    <tr><td>B04</td><td><strong>Bảo</strong></td>
547	        <td>Viết <code>policy/zones.yml</code> + <code>aliases</code> + <code>rules[]</code>: mỗi rule có <code>id: POL-xxx</code>,
548	        <code>action</code>, <code>log</code>, <code>reason</code>, <code>test: T-xx</code>. Thêm alias <code>ADMIN_SRC</code> (10.0.0.6)
549	        cho đường bastion. Kèm schema validation + <code>yamllint</code>. Lập bảng 24 combo (zone, đích, port) làm nguồn chân lý cho T-07.</td>
550	        <td>5</td><td>YAML được cả hai duyệt; <code>make policy-lint</code> xanh</td></tr>
551	    <tr><td>B05</td><td><strong>Bảo</strong></td>
552	        <td>Route MGMT xuyên 2 máy + rule permit MGMT → các vùng cho scrape/SSH/syslog (POL-006, POL-007). Bảo thêm vào YAML, Hùng áp dụng.</td>
553	        <td>1</td><td><code>obs</code> thu thập được từ MGMT sang DMZ-FRONT</td></tr>
554	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Hùng <em>xoá toàn bộ</em> alias/rule tạo tay và thay bằng đúng mô hình YAML của Bảo.
555	        Đây là lần đầu "chính sách là mã nguồn" được chứng minh — làm ở ngày 4, không dồn sang GĐ2.</td></tr>
556	</table>
557	
558	<h3>GĐ2 — CARP + renderer API + HAProxy (ngày 4–6) · 20h</h3>
559	<table>
560	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
561	    <tr><td>H03</td><td><strong>Hùng</strong></td>
562	        <td>CARP 5 vhid (WAN, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT), advskew 0/100, tắt <code>preempt</code>.
563	        <strong>pfsync chạy trên vmnet-sync</strong>, không để qua WAN. cfgsync với user quyền tối thiểu.
564	        Test T-04 (iperf3 + ssh đang chạy phải sống sót), T-05 (cắt vmnet-sync → không có 2 MASTER),
565	        T-06 (sửa tay trên backup → master không bị ghi đè im lặng).</td>
566	        <td>8</td><td>T-04, T-05, T-06 pass kèm số liệu</td></tr>
567	    <tr><td>B06</td><td><strong>Bảo</strong></td>
568	        <td><em>Bước 0 (30 phút, bắt buộc):</em> bật API trên OPNsense, <code>curl</code> 3 endpoint
569	        (<code>searchAlias</code>, <code>rule_filter/addRule</code>, <code>filter/apply</code>) để xác nhận tên theo đúng phiên bản.
570	        Rồi viết renderer YAML → API, idempotent (chạy 2 lần ra cùng rule set; xoá khỏi YAML thì rule biến mất trên thiết bị).
571	        Apply + reload, đo số state trước/sau để chứng minh NFR-02.</td>
572	        <td>6</td><td>T-08 pass: thêm rule lúc 30 req/s, 0 gián đoạn, state không giảm</td></tr>
573	    <tr><td>H04</td><td><strong>Hùng</strong></td>
574	        <td>HAProxy ×2: TLS termination (ALPN h2), mTLS xuống backend, <code>option httpchk GET /healthz</code> +
575	        <code>expect status 200</code>, stats bind MGMT. Đóng role Ansible.
576	        <em>(Chuyển từ Bảo sang Hùng để cân giờ — HAProxy chạy trên VM của Hùng.)</em></td>
577	        <td>6</td><td>Handshake qua VIP OK; backend không có client cert hợp lệ thì bị từ chối</td></tr>
578	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy renderer lên thiết bị của Hùng (lần đầu có mặt Hùng).
579	        Rủi ro lớn nhất của cả dự án nằm ở đây: nếu API không như mong đợi thì kích hoạt phương án B (render <code>config.xml</code> + reboot) —
580	        độ khó policy tụt 4.7 xuống 4.2 nhưng lịch trình sống.</td></tr>
581	</table>
582	
583	<h3>GĐ3 — IPS inline + dịch vụ + DB nền (ngày 6–8) · 22h</h3>
584	<table>
585	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
586	    <tr><td>H05</td><td><strong>Hùng</strong></td>
587	        <td>Suricata <strong>inline NFQUEUE</strong> trên WAN + DMZ-FRONT + DMZ-APP; ruleset (emerging + tự viết cho hành vi lab);
588	        đo latency tăng thêm và số state bị ảnh hưởng.</td>
589	        <td>6</td><td>nmap từ attacker sinh alert và bị chặn theo rule đã bật</td></tr>
590	    <tr><td>H06</td><td><strong>Hùng</strong></td>
591	        <td>PostgreSQL ×2 streaming replication, <code>synchronous_commit=on</code>, <code>hostssl</code> + scram, replication slot.</td>
592	        <td>4</td><td><code>pg_stat_replication</code> thấy standby; ghi primary thì đọc được ở standby</td></tr>
593	    <tr><td>B07</td><td><strong>Bảo</strong></td>
594	        <td>Policy validator: quét 24 combo từ attacker/sensor/web/db, so với YAML, đọc counter từng rule, xuất CSV. Thêm <code>make drift</code>.</td>
595	        <td>4</td><td>T-07 pass 24/24; mọi rule được kiểm đều có counter &gt; 0</td></tr>
596	    <tr><td>B08</td><td><strong>Bảo</strong></td>
597	        <td>Keepalived VIP multicast (vmnet của VMware xử lý được, không cần <code>unicast_peer</code>) +
598	        <code>track_script</code> gọi <code>haproxy -c</code>.</td>
599	        <td>3</td><td>T-03 pass: VIP đổi chủ ≤ 10 s</td></tr>
600	    <tr><td>B09</td><td><strong>Bảo</strong></td>
601	        <td>App 4 endpoint (<code>/healthz</code>, <code>/whoami</code>, <code>GET/POST /note</code>, <code>/session</code>),
602	        session lưu trong DB, Apache ×2 + hardening (SSH key-only, ẩn banner, CSP/HSTS), role Ansible.</td>
603	        <td>5</td><td>T-01, T-02 pass; phiên còn sau khi chết 1 web node</td></tr>
604	    <tr><td colspan="5"><strong>Checkpoint 1 (hết ngày 8):</strong> T-01, T-02, T-03, T-04, T-07 pass.
605	        Nếu T-04 hoặc T-07 chưa đạt thì cắt phạm vi <em>ngay bây giờ</em>, không phải ngày 12.</td></tr>
606	</table>
607	
608	<h3>GĐ4 — An ninh sâu + khôi phục (ngày 8–10) · 20.5h</h3>
609	<table>
610	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
611	    <tr><td>H07</td><td><strong>Hùng</strong></td>
612	        <td><code>promote.sh</code>: repmgr promote → gán DB VIP + <code>arping -A</code> → refresh alias firewall →
613	        <strong>fence</strong> node cũ (stop postgres + rule chặn 5432 từ IP của nó). Test <code>kill -9</code>, đo RTO và RPO.</td>
614	        <td>5</td><td>T-13a: leader mới ≤ 40 s, commit cuối còn, node cũ không ghi được</td></tr>
615	    <tr><td>H08</td><td><strong>Hùng</strong></td>
616	        <td><code>mod_security2</code> + OWASP CRS, <code>SecRuleEngine On</code>, ParanoiaLevel 2,
617	        file overrides trong Git mỗi rule có <code>Reason:</code>.</td>
618	        <td>4</td><td>T-12: 15 request hợp lệ → 0 block sai</td></tr>
619	    <tr><td>H09</td><td><strong>Hùng</strong></td>
620	        <td>Test <strong>fail-closed</strong>: dừng Suricata khi đang có kết nối → xác nhận hành vi (chặn hay mở),
621	        thêm alert "IPS xuống", viết đoạn công bố hành vi + lý do lựa chọn.</td>
622	        <td>2</td><td>T-10 pass + có đoạn văn thiết kế</td></tr>
623	    <tr><td>H10</td><td><strong>Hùng</strong></td>
624	        <td>Chống flood ở perimeter: <code>max-src-conn</code>, state table limit, syncookies; test SYN flood từ attacker.</td>
625	        <td>2</td><td>T-14a: 50k pkt/s không làm sập VIP, có số liệu state table</td></tr>
626	    <tr><td>H11</td><td><strong>Hùng</strong></td>
627	        <td>Hardening thiết bị biên: tắt service thừa, GUI TLS cert nội bộ, khoá root shell, anti-spoofing, bogon,
628	        private-network, NTP, backup <code>config.xml</code> có mã hoá.</td>
629	        <td>2</td><td>Checklist NFR-11 đạt, kèm ảnh trước/sau</td></tr>
630	    <tr><td>B10</td><td><strong>Bảo</strong></td>
631	        <td><strong>Tài liệu hoá out-of-band management path</strong> (mục 2.4 #7): viết rõ đường điều khiển đi qua
632	        hypervisor host chứ không qua perimeter, liệt kê hệ quả với NFR-13, và kiểm bastion vẫn còn nghĩa bằng test
633	        "attacker từ vmnet-wan thử SSH vào bastion phải bị từ chối"</td>
634	        <td>0.5</td><td>Có đoạn văn trong báo cáo + kết quả test SSH-from-WAN = block</td></tr>
635	    <tr><td>B11</td><td><strong>Bảo</strong></td>
636	        <td>step-ca: 2 authority (server + client), TTL 7 ngày, script gia hạn, cert cho lb/web phục vụ mTLS.</td>
637	        <td>3</td><td>mTLS dùng cert nội bộ, không còn cert tự sinh tạm</td></tr>
638	    <tr><td>B12</td><td><strong>Bảo</strong></td>
639	        <td>Remote syslog 3 nguồn (firewall, WAF, app) → Loki; index theo <code>POLICY-ID</code> và <code>X-Request-ID</code>.</td>
640	        <td>2</td><td>Truy vết được 1 request xuyên LB → web → DB bằng log</td></tr>
641	    <tr><td colspan="5"><strong>Checkpoint 2 (hết ngày 10):</strong> T-09, T-10, T-11, T-12, T-13 pass.
642	        Nếu T-13 chưa đạt, chạy bảng cắt khẩn cấp ở mục 11 <em>trong ngày 10</em>.</td></tr>
643	</table>
644	
645	<h3>GĐ5 — Kiểm chứng tấn công &amp; quan sát (ngày 10–12) · 16h</h3>
646	<table>
647	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
648	    <tr><td>B13</td><td><strong>Bảo</strong></td>
649	        <td>Prometheus + node/haproxy/postgres exporter, Grafana 3 dashboard (Dịch vụ / Perimeter+IPS / DB),
650	        Alertmanager 6 alert: mất MASTER CARP, IPS xuống, rule counter bất thường, 5xx&gt;1%, DB leader đổi, backup &gt;24h.</td>
651	        <td>4</td><td>Ít nhất 1 alert bắn thật trong điều kiện test</td></tr>
652	    <tr><td>B14</td><td><strong>Bảo</strong></td>
653	        <td>Attack harness 4 lớp từ <code>attacker</code>: (1) scan, (2) 30 payload web, (3) SSH brute force, (4) egress attempt từ web ra WAN.
654	        Mỗi lớp lấy bằng chứng từ <code>sensor</code> (tcpdump/Zeek) rồi đối chiếu log phòng thủ → bảng "gửi gì / ghi nhận gì / lệch ở đâu".
655	        Map MITRE: T1046, T1190, T1110, T1048, T1562.110.</td>
656	        <td>7</td><td>T-09, T-14 pass; bảng đối chiếu sensor-vs-defender hoàn chỉnh</td></tr>
657	    <tr><td>H12</td><td><strong>Hùng</strong></td>
658	        <td>pgBackRest: WAL archive + full + incremental lên repo (ssh/NFS sang obs). <strong>Diễn tập PITR</strong> tới timestamp
659	        chỉ định trên instance mới, verify 3 bản ghi mốc.</td>
660	        <td>5</td><td>T-13b pass + biên bản thời gian và dung lượng WAL</td></tr>
661	    <tr><td colspan="5"><strong>Mốc ghép:</strong> Bảo chạy attack harness <em>trong khi</em> Hùng chạy PITR.
662	        Đây là lần duy nhất hai người thao tác đồng thời, và là phép thử thật cho việc lab có đứng dưới tải tấn công hay không.</td></tr>
663	</table>
664	
665	<h3>GĐ6 — Test, rebuild, báo cáo (ngày 12–14) · 16h</h3>
666	<table>
667	    <tr><th>Mã</th><th>Ai</th><th>Việc cụ thể</th><th>h</th><th>Xong khi</th></tr>
668	    <tr><td>H13</td><td><strong>Hùng</strong></td><td>Chạy lại 8 kịch bản phần biên: T-04, T-05, T-06, T-08, T-10, T-11, T-13, T-14a</td><td>3</td><td>8/8 pass, có CSV</td></tr>
669	    <tr><td>B15</td><td><strong>Bảo</strong></td><td>Chạy lại 6 kịch bản phần dịch vụ: T-01, T-02, T-03, T-07, T-09, T-12</td><td>3</td><td>6/6 pass</td></tr>
670	    <tr><td>B16</td><td><strong>Bảo</strong></td><td><code>run_matrix.sh</code> + schema CSV + <code>report.py</code> dựng bảng và biểu đồ</td><td>2</td><td>Một lệnh ra toàn bộ số liệu</td></tr>
671	    <tr><td>H14 / B17</td><td><strong>Mỗi người 1.5</strong></td><td>Rebuild drill ≤ 30 phút: xoá dịch vụ, dựng lại bằng Ansible, chạy lại test chính</td><td>3</td><td>Biên bản thời gian + kết quả test sau dựng</td></tr>
672	    <tr><td>B18</td><td><strong>Bảo</strong></td><td>Báo cáo: mô hình chính sách, policy-as-code, bằng chứng sensor-vs-log, bảng MITRE, trade-off đã cắt</td><td>3</td><td>Bản nháp hoàn chỉnh</td></tr>
673	    <tr><td>H15</td><td><strong>Hùng</strong></td><td>Báo cáo phần perimeter/CARP/IPS/PITR + video demo 6 kịch bản (T-04, T-08, T-09, T-10, T-13, T-14)</td><td>2</td><td>Video + snapshot <code>green</code> cuối</td></tr>
674	</table>
675	
676	<h3>Tổng kết phân công</h3>
677	<table>
678	    <tr><th>Giai đoạn</th><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Tổng</th><th>Điều kiện ra</th></tr>
679	    <tr><td>GĐ0 Hạ tầng + Tailscale</td><td>1–2</td><td>3.5</td><td>5</td><td>8.5</td><td>ansible ping đủ 12 VM + ProxyJump vào từng vùng</td></tr>
680	    <tr><td>GĐ1 Perimeter + mô hình</td><td>2–4</td><td>6</td><td>6</td><td>12</td><td>curl chạm dịch vụ giả; YAML được duyệt</td></tr>
681	    <tr><td>GĐ2 CARP + renderer + LB</td><td>4–6</td><td>14</td><td>6</td><td>20</td><td>T-04, T-05, T-06, T-08</td></tr>
682	    <tr><td>GĐ3 IPS + dịch vụ + DB nền</td><td>6–8</td><td>10</td><td>12</td><td>22</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-07</td></tr>
683	    <tr><td>GĐ4 An ninh sâu + khôi phục</td><td>8–10</td><td>15</td><td>5.5</td><td>20.5</td><td><strong>Checkpoint 2</strong>: T-09 tới T-13</td></tr>
684	    <tr><td>GĐ5 Kiểm chứng + quan sát</td><td>10–12</td><td>5</td><td>11</td><td>16</td><td>T-14 + PITR + alert thật</td></tr>
685	    <tr><td>GĐ6 Test + báo cáo</td><td>12–14</td><td>6.5</td><td>9.5</td><td>16</td><td>14/14 pass + video</td></tr>
686	    <tr><td><strong>Tổng</strong></td><td></td><td><strong>60</strong></td><td><strong>55.5</strong></td><td><strong>115.5</strong></td><td>82% quỹ, 24.5 giờ đệm</td></tr>
687	</table>
688	<div class="note">
689	<strong>Hai người cố tình không đối xứng.</strong> Hùng tập trung giờ ở GĐ2 + GĐ4 (29h) vì đó là CARP và an ninh sâu — phần cần hiểu thiết bị.
690	Bảo tập trung ở GĐ0 + GĐ3 + GĐ5 (28h) vì đó là control plane, validator và kiểm chứng tấn công — phần cần viết code và chạy script.
691	Chia đối xứng sẽ buộc một người phải làm việc của người kia ở trình độ thấp hơn.
692	</div>
693	
694	<h2>10. Lịch 14 ngày theo mã việc</h2>
695	<table>
696	    <tr><th>Ngày</th><th>Hùng</th><th>Bảo</th><th>Mốc chung cuối ngày</th></tr>
697	    <tr><td>1</td><td>H01 VMware + 12 VM + 6 vmnet riêng</td><td>B01 Tailscale 2 máy + tắt key expiry + OpenSSH Server trên Hùng</td><td><code>ssh -J hung@100.64.x ops@&lt;VM&gt;</code> vào được 1 VM bất kỳ</td></tr>
698	    <tr><td>2</td><td>H01 tiếp: linked clone, snapshot <code>clean</code>, chrony một source</td><td>B02 attacker + sensor, B03 repo + <code>ansible.cfg</code> + <code>make check</code></td><td><code>ansible all -m ping</code> xanh đủ 12 VM</td></tr>
699	    <tr><td>3</td><td>H02 OPNsense 5 vùng + DNAT 443→LB VIP</td><td>B04 YAML policy + bảng 24 combo</td><td>attacker chạm được dịch vụ giả qua perimeter</td></tr>
700	    <tr><td>4</td><td>H02 routing + H03 CARP vhid</td><td>B04 tiếp, B05 route MGMT nội bộ + rule bastion</td><td><strong>Giao YAML cho Hùng, xoá toàn bộ rule tạo tay</strong></td></tr>
701	    <tr><td>5</td><td>H03 pfsync state sync</td><td>B06 <em>verify API 30 phút</em> rồi renderer</td><td>API xanh, hoặc quyết định phương án B (<code>config.xml</code>)</td></tr>
702	    <tr><td>6</td><td>H03 cfgsync, H04 HAProxy TLS/mTLS</td><td>B06 renderer + apply dưới tải</td><td>T-04 pass (session sống sót), T-08 pass</td></tr>
703	    <tr><td>7</td><td>H04 HAProxy + H06 PostgreSQL streaming</td><td>B09 app + web ×2</td><td>T-01, T-02 pass</td></tr>
704	    <tr><td>8</td><td>H05 Suricata inline IPS</td><td>B07 policy validator, B08 Keepalived VIP</td><td><strong>Checkpoint 1</strong>: T-01, T-02, T-03, T-04, T-07</td></tr>
705	    <tr><td>9</td><td>H07 promote/fencing, H08 CRS, H09 fail-closed</td><td>B10 tài liệu hoá out-of-band mgmt path, B11 step-ca</td><td>T-09, T-10, T-12 pass</td></tr>
706	    <tr><td>10</td><td>H10 state limit, H11 hardening, H12 PITR (bắt đầu)</td><td>B12 syslog → Loki</td><td><strong>Checkpoint 2</strong>: T-13, T-14 pass</td></tr>
707	    <tr><td>11</td><td>H12 PITR drill + verify</td><td>B13 Prometheus/Grafana/6 alert, B14 attack harness + sensor</td><td>Chạy đủ 14 kịch bản lần đầu</td></tr>
708	    <tr><td>12</td><td>H13 chạy lại 8 kịch bản biên, H14 rebuild drill</td><td>B15 chạy lại 6 kịch bản dịch vụ, B16 <code>run_matrix.sh</code>, B17 rebuild drill</td><td>14/14 pass hoặc ghi chú fail trung thực</td></tr>
709	    <tr><td>13</td><td>H15 báo cáo perimeter + video demo</td><td>B18 báo cáo chính sách + MITRE + trade-off</td><td>Bản nháp hoàn chỉnh + video dự phòng</td></tr>
710	    <tr><td>14</td><td colspan="2">Dự phòng: chạy lại test cuối, luyện phản biện phần của đối phương</td><td>Sẵn sàng nộp</td></tr>
711	</table>
712	<div class="note">
713	<strong>Hai ngày then chốt.</strong> Ngày 1 chỉ có một việc thật: xác nhận ProxyJump vào được VM — mất 20 phút, và nếu không xong thì
714	dừng lại bàn phương án khác trước khi đầu tư thêm. Ngày 5 là bước <em>verify API OPNsense</em>: trượt ở đây bạn còn 3 ngày
715	để đổi sang render <code>config.xml</code> + reboot; thử ở ngày 8 thì không còn đường lùi.
716	</div>
717	
718	<h2>11. Bảng cắt khẩn cấp (kích hoạt ở Checkpoint 1 hoặc 2)</h2>
719	<table>
720	    <tr><th>Thứ tự</th><th>Cắt</th><th>Giờ giữ lại</th><th>Độ khó sau cắt</th></tr>
721	    <tr><td>1</td><td>H10 state limit + SYN flood</td><td>2</td><td>Perimeter 4.5 → 4.3</td></tr>
722	    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
723	    <tr><td>3</td><td>B14 phần đối chiếu sensor-vs-defender (chỉ dùng log phòng thủ)</td><td>3</td><td>Attack validation 4.2 → 3.9</td></tr>
724	    <tr><td>4</td><td>H09 test fail-closed (chuyển thành mô tả thiết kế + lý do)</td><td>2</td><td>IPS 4.6 → 4.3</td></tr>
725	    <tr><td>5</td><td>H08 CRS xuống DetectionOnly + còn 10 payload</td><td>2</td><td>WAF 4.2 → 3.6 ⚠</td></tr>
726	    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
727	    <tr><td colspan="2"><strong>TUYỆT ĐỐI KHÔNG CẮT</strong></td>
728	        <td colspan="2">H03 (CARP + pfsync), B06 (policy-as-code + apply không gián đoạn), H05 (IPS blocking),
729	        B07 (ma trận chính sách) — bốn thứ định danh bản v4. Cắt một trong bốn thì nên nộp bản v3.</td></tr>
730	</table>
731	
732	<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
733	<table>
734	    <tr><th>Rủi ro</th><th>Phòng ngừa</th></tr>
735	    <tr><td><strong>Tailscale hết hạn key sau 180 ngày</strong> → giữa kỳ học hai máy mất nhau, thông báo lại rất ít ngữ cảnh</td>
736	        <td>Chạy <code>tailscale set --expiry=0</code> trên cả hai máy <em>ngay ngày 1</em>, và ghi vào <code>docs/interfaces.md</code></td></tr>
737	    <tr><td>Cố bật <code>--advertise-routes</code> + IP forwarding trên Windows để "route vào VM"</td>
738	        <td><strong>Đừng.</strong> Chỉ dùng ProxyJump và <code>-L</code>: host đã có adapter trên từng vmnet nên nó tới được mọi VM mà không cần route. Đây là hố 2 giờ đã được ghi nhận</td></tr>
739	    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
740	    <tr><td>Mất Internet là mất quyền điều khiển lab</td>
741	        <td>Khi hai máy <em>cùng một mạng LAN</em>, Tailscale tự kết nối trực tiếp (không qua DERP) nên gần như không rủi ro.
742	        Khi ở khác mạng, luôn <code>tailscale status</code> xem là <code>direct</code> hay <code>DERP</code>; đang DERP mà chạy test timing thì ghi rõ vào biên bản</td></tr>
743	    <tr><td>Máy Hùng là điểm nghẽn: Hùng tắt máy thì Bảo không làm gì được ngoài viết code</td>
744	        <td>Quy ước giờ trực: Hùng bật lab trong khung Bảo cần (thông báo trước 1 ngày); phần việc của Bảo ngày đó chuyển sang B04/B18</td></tr>
745	    <tr><td>Đường quản trị không đi qua firewall → dễ bị hỏi "anh kiểm soát admin path thế nào"</td>
746	        <td>B10: viết rõ đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter,
747	        và bastion trong MGMT vẫn tồn tại để POL-005 còn ý nghĩa</td></tr>
748	    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
749	        <td>Ngày 5 <code>curl</code> thử 3 endpoint trước khi viết playbook; khoá <strong>cùng một phiên bản</strong> cho cả 2 con opns; luôn có phương án B</td></tr>
750	    <tr><td>cfgsync ghi đè cấu hình đang làm dở</td><td>Tắt auto-sync khi làm việc, chỉ sync khi chủ động; snapshot trước mỗi lần sync</td></tr>
751	    <tr><td>IPS inline làm sập kết nối ngay buổi demo</td><td>Nút tắt IPS trong 1 lệnh + snapshot <code>IPS-off</code>; test fail-closed ở ngày 9 chứ không phải ngày 14</td></tr>
752	    <tr><td>Hai người cùng sửa rule</td><td>Chỉ Bảo sửa <code>policy/*.yml</code>; Hùng chỉ chạy playbook; sửa trên GUI bị <code>make drift</code> bắt</td></tr>
753	    <tr><td>Lệch đồng hồ làm PITR và đối chiếu log sai</td><td>Một source NTP cho 12 VM + 2 host OS; kiểm <code>date</code> trước mỗi lần đo</td></tr>
754	</table>
755	
756	<h2>13. Sáu mươi phút đầu tiên — làm đủ rồi mới chia việc</h2>
757	<ol>
758	    <li>Cài VMware Workstation Pro trên máy Hùng (bản miễn phí cho cá nhân). Máy Bảo chỉ cần Tailscale + trình duyệt + WSL2.</li>
759	    <li>Cài Tailscale trên <strong>cả hai máy</strong>, đăng nhập cùng tailnet, chạy <code>tailscale set --expiry=0</code> mỗi máy.
760	        Ghi lại IP của nhau vào <code>docs/interfaces.md</code>.</li>
761	    <li>Trên máy Hùng: bật OpenSSH Server (<code>Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0</code>,

#### Thinking

**Assessing VMware network and memory constraints****Finalizing plan assumptions**

Kế hoạch trong `D:\Lab\ha-lb-security-lab.html` có cấu trúc tốt, nhưng chưa sẵn sàng triển khai nguyên trạng trên môi trường hiện tại. Phụ thuộc lớn nhất là: dựng được 6 vmnet, giảm áp lực RAM WSL2, xác nhận đường `Tailscale → Windows OpenSSH → ProxyJump → VM`, rồi mới đầu tư vào OPNsense/CARP.

**Kết luận kiểm tra nhanh**

- Không nên bắt đầu bằng việc tạo đủ 12 VM rồi bật đồng thời. Tổng RAM thiết kế là khoảng 17 GB khi bật đủ, cộng WSL2 đang dùng 13–14 GB, Windows/VMware và cache sẽ vượt biên an toàn của máy 32 GB.
- Chưa thể coi `VMnet1/VMnet8` là đủ. Cần tạo thêm các mạng private riêng: WAN, SYNC, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT. Đây là thao tác trên Windows/VMware, assistant không thể thực hiện trong workspace.
- `Tailscale` không thay thế L2. Phương án ProxyJump chỉ hợp lệ nếu Windows host có adapter trên từng vmnet và có thể TCP-connect tới VM. Phải kiểm tra thực tế trước khi tạo policy.
- NFR-13 trong tài liệu bị hạ cấp về ý nghĩa: `obs`, `ca`, `sensor` vẫn cùng máy vật lý với dịch vụ. Nên ghi rõ đây là phân tách logic, không phải giám sát ngoài host.
- Mốc “T-04 session TCP không đứt qua CARP failover” cần xem là mục tiêu thử nghiệm, không phải giả định. pfsync/CARP trên VMware host-only phải được chứng minh sớm.
- Kế hoạch hiện nói “Ansible ping đủ 12 VM” trước khi chỉ rõ image, IP, SSH user/key và cách cấp IP cho OPNsense. Nên tách kiểm tra reachability của OPNsense khỏi Linux VM.

## Thứ tự phase đề xuất

### Phase 0 — Dọn điều kiện máy chủ và quyết định phạm vi

**Mục tiêu**

Xác nhận máy đủ sức chạy lab theo từng nhóm VM, không cố dựng toàn bộ ngay.

**Việc user phải làm trên Windows**

- Bật Windows OpenSSH Server, đặt `Automatic`, cấu hình key-only.
- Cài và đăng nhập Tailscale trên hai máy; tắt key expiry nếu chính sách tailnet cho phép.
- Đặt Windows High Performance, không sleep khi chạy lab.
- Tạo 6 custom private vmnet trong VMware, không bridged:
  - WAN `10.0.0.0/24`
  - SYNC `192.168.50.0/24`
  - DMZ-FRONT `192.168.20.0/24`
  - DMZ-APP `192.168.21.0/24`
  - TRUSTED `192.168.30.0/24`
  - MGMT `192.168.99.0/24`
- Xác nhận host adapter của Windows tồn tại trên các vmnet cần dùng.

**Điều chỉnh tài nguyên**

Tạm đặt WSL2 thấp hơn, ví dụ 8–10 GB và 6–8 vCPU trong giai đoạn chạy VM. Không nên chạy WSL2 ở mức 14 GB khi obs/Grafana/DB/OPNsense đang bật.

Nên dùng các profile bật VM:

- `core`: 2 OPNsense, 2 LB, 2 web, 2 PostgreSQL, khoảng 10–12 GB.
- `observe`: thêm `obs`, `ca`, khoảng 13–15 GB.
- `attack`: thêm `attacker`, `sensor` chỉ khi test, khoảng 16–19 GB.
- Tắt attacker/sensor sau từng test như tài liệu đã quy định.

**Checkpoint P0 — Pass/Fail**

Pass khi:

- 6 vmnet tồn tại đúng subnet, không bridged.
- Host Windows ping/TCP-connect được tới một VM thử trên từng vùng.
- Bảo SSH được vào Windows Hùng qua Tailscale.
- `ssh -J` vào được ít nhất một VM Linux.
- WSL2 + VM core giữ ổn định ít nhất 30 phút, không paging/thrashing nghiêm trọng.

Fail thì chưa tạo 12 VM hoàn chỉnh. Rollback là giữ lại 2 OPNsense + 1 LB + 1 web làm vertical slice, hoặc chuyển sang làm chung trực tiếp trên máy Hùng.

**Ai làm được trong workspace**

Assistant có thể giúp thiết kế inventory, ma trận IP, checklist kiểm tra, cấu trúc repo và lệnh xác minh sau khi user đã tạo môi trường. Hiện `D:\Lab` chưa có repo nên chưa có gì để tự chạy.

### Phase 1 — Tạo VM theo lát dọc tối thiểu

Không nên tạo 12 VM cùng lúc. Thứ tự nên là:

1. `opns1`, `opns2`
2. `lb1`, `lb2`
3. `web1`, `web2`
4. `pg1`, `pg2`
5. `obs`, `ca`
6. `attacker`, `sensor`

Mỗi nhóm chỉ thêm sau khi nhóm trước đạt checkpoint. Dùng linked clone nếu template đã được chuẩn bị và kiểm tra tương thích; nếu chưa có template, snapshot sạch đáng tin cậy quan trọng hơn việc cố làm linked clone ngay.

**Checkpoint P1**

- Mỗi VM có đúng NIC và đúng vmnet.
- Không có NIC nào vô tình nối vào bridged/NAT ngoài dự kiến.
- IP, gateway, hostname, NTP được ghi lại.
- Snapshot `clean` tồn tại trước khi cấu hình dịch vụ.

Rollback: xóa khỏi inventory nhóm VM chưa cần, giữ lại core profile. Không cần dựng attacker/sensor để chứng minh routing cơ bản.

### Phase 2 — OPNsense một node trước, rồi mới HA

Thứ tự trong tài liệu nên đảo nhẹ:

1. Cấu hình `opns1` với 5 zone và interface sync.
2. Kiểm tra routing và DNAT tới dịch vụ giả trên LB.
3. Tạo alias/policy tối thiểu thủ công.
4. Cấu hình `opns2`.
5. CARP theo từng zone.
6. pfsync trên `vmnet-sync`.
7. cfgsync sau khi CARP và pfsync ổn định.

Không nên bật Suricata, policy renderer hoặc flood test trong phase này.

**Checkpoint P2**

- Attacker tới được dịch vụ giả qua WAN → DNAT → DMZ-FRONT.
- WAN không tới được DB/MGMT trái phép.
- GUI chỉ qua HTTPS.
- Hai node OPNsense nhìn thấy nhau trên sync.
- Có đúng một CARP master mỗi VIP.
- Cắt sync không tạo split-brain.
- Session dài qua failover được đo bằng số liệu, không chỉ quan sát bằng mắt.

**Rollback**

- Tắt cfgsync, quay snapshot trước HA.
- Dùng một OPNsense để tiếp tục phát triển app/policy nếu CARP chưa ổn.
- Không chuyển sang IPS khi T-04 chưa có kết quả.

### Phase 3 — Repo, policy-as-code và API OPNsense

Đây là một critical path và phải làm “spike” trước renderer đầy đủ.

**Thứ tự**

1. Xác nhận phiên bản OPNsense giống nhau trên cả hai node.
2. Tạo API key quyền tối thiểu.
3. Gọi thử các endpoint alias, rule và apply.
4. Ghi lại response thực tế của phiên bản đang dùng.
5. Chỉ sau đó mới thiết kế renderer idempotent.
6. Thêm validator 24 combo và drift check.
7. Xóa rule tạo tay, để YAML trở thành nguồn chân lý duy nhất.

**Checkpoint P3**

- `policy-lint` pass.
- Apply lần đầu thành công.
- Apply lần hai không tạo bản sao.
- Xóa một rule trong YAML làm rule biến mất trên thiết bị.
- Thêm rule dưới tải không làm mất state hoặc tạo 5xx.
- Mỗi rule có `POLICY-ID`, log và test mapping.

**Rollback**

Phương án B trong tài liệu — render `config.xml` — chỉ nên là fallback có kiểm soát, không dùng reboot như đường triển khai thường xuyên. Nếu API không dùng được, giữ policy YAML/validator nhưng đánh dấu NFR-02 “chưa đạt đầy đủ”, thay vì giả vờ có apply không gián đoạn.

### Phase 4 — LB, web và DB nền

Thứ tự nên là:

1. HAProxy một node với backend web.
2. Web health check và mTLS.
3. HAProxy thứ hai và Keepalived VIP.
4. PostgreSQL streaming replication.
5. Session lưu DB.
6. DB VIP và cơ chế promote/fence.
7. PITR.

Không nên chạy failover DB trước khi có:

- fencing rõ ràng;
- cách xác định node cũ không còn ghi;
- xác nhận app chỉ dùng DB VIP;
- backup repository trên `obs`.

**Checkpoint P4**

- T-01, T-02, T-03 pass.
- Web không có client certificate hợp lệ bị từ chối.
- Session còn sau khi một web node chết.
- PostgreSQL standby theo kịp.
- DB failover không tạo hai writer.
- PITR khôi phục được ba bản ghi mốc.

Rollback/cắt phạm vi:

1. Bỏ state-limit/SYN flood trước.
2. Gộp sensor vào attacker nếu thiếu RAM.
3. Bỏ auto DB failover nhưng giữ streaming + manual promote + PITR.
4. Không bỏ DB VIP nếu mục tiêu vẫn là chứng minh app không đổi connection string.

### Phase 5 — IPS/WAF và observability

Chỉ bật inline IPS sau khi có snapshot `IPS-off` và core path đã chạy ổn.

**Thứ tự**

1. Suricata detection-only để xác nhận traffic path.
2. Bật blocking trên WAN.
3. Mở rộng sang DMZ-FRONT.
4. Cuối cùng mới DMZ-APP.
5. Kiểm tra fail-closed/fail-open theo hành vi thực tế.
6. Cấu hình WAF CRS.
7. Gửi log về obs.
8. Thêm Prometheus/Grafana/alert sau khi log cơ bản đã ổn.

**Checkpoint P5**

- Scan tạo alert và bị chặn theo thiết kế.
- Dừng Suricata có hành vi đã công bố và có alert.
- 15 request hợp lệ không bị WAF chặn sai.
- Có ít nhất một alert thật từ CARP/IPS/DB.
- Có thể truy vết một request từ LB qua web tới DB.
- Sensor chứng minh được “đã gửi gì”; defender log chứng minh “đã xử lý gì”.

Rollback:

- Tắt blocking, quay `IPS-off`, giữ detection-only nếu inline làm hỏng lab.
- Hạ CRS về DetectionOnly nếu false positive phá T-01/T-02.
- Bỏ dashboard đẹp trước, giữ raw logs và một alert có bằng chứng.

### Phase 6 — Attack validation, ma trận 14 test và rebuild

Chạy test theo thứ tự ít phá hoại đến phá hoại:

1. T-01, T-02, T-03
2. T-07, T-08
3. T-04, T-05, T-06
4. T-09, T-11, T-12
5. T-13
6. T-10
7. T-14

Mỗi test cần snapshot `before-T-xx`, timestamp đồng bộ, trạng thái `direct/DERP` của Tailscale nếu có đo timing, và kết quả pass/fail rõ ràng.

**Checkpoint cuối**

- 14 test có kết quả, không nhất thiết 14/14 pass.
- Mỗi fail có nguyên nhân, ảnh hưởng, workaround và phạm vi bị hạ cấp.
- Rebuild drill đo từ trạng thái xác định, không tính thời gian tải ISO hoặc sửa thủ công ngoài quy trình.
- NFR-13 phải ghi là “logical separation on one physical host”, không trình bày như độc lập vật lý.

## Các điểm cần sửa trong kế hoạch gốc

- “Tạo 12 VM ở GĐ0” không phù hợp với WSL2 đang dùng 13–14 GB; nên tạo theo profile và bật theo nhóm.
- “Ansible ping đủ 12 VM” quá sớm; OPNsense và Linux VM cần hai loại bootstrap/check khác nhau.
- `ADMIN_SRC: 10.0.0.6` chưa khớp rõ với topology Tailscale/Windows host. Cần xác nhận IP nguồn thực tế khi Windows host kết nối tới VM; không được đoán.
- Tài liệu nói sensor promiscuous trên vmnet WAN; cần kiểm tra VMware virtual switch có cho phép promiscuous/capture như mong muốn. Đây là việc user phải xác minh trên VMware, không nên coi là mặc định.
- Keepalived multicast trên VMware cần một smoke test nhỏ trước khi phụ thuộc vào T-03.
- T-06 “sửa tay trên backup” cần định nghĩa rõ expected behavior: cảnh báo drift, không tự ghi đè, và cách khôi phục cấu hình chuẩn.
- T-14 “50k pkt/s” có thể quá cao hoặc thiếu ý nghĩa trên một laptop/VM. Nên ghi cả tốc độ thực tế đạt được và giới hạn phần cứng; không tuyên bố đạt ngưỡng nếu generator không phát được tải.
- NFR-10 ghi “RPO = 0 khi mất DB primary” chỉ hợp lý trong điều kiện synchronous replication đã commit thành công; cần phân biệt commit đã xác nhận với giao dịch đang in-flight.
- Không nên cài thêm Ansible/Docker/Podman chỉ vì danh sách công nghệ. Với kế hoạch hiện tại, Ansible + các binary cần thiết là đủ; Docker/Podman chỉ thêm nếu một dịch vụ quan sát thực sự cần container.

## Việc user phải thao tác ngoài workspace

- Cấu hình Windows OpenSSH, Tailscale, firewall Windows và startup.
- Tạo/chỉnh custom vmnet trong VMware.
- Tạo VM, gắn NIC, cài OS/OPNsense, snapshot, power on/off.
- Kiểm tra VMware multicast/promiscuous behavior.
- Điều chỉnh `.wslconfig` và khởi động lại WSL2.
- Xác nhận tailnet policy, key expiry, kết nối direct/DERP.
- Thao tác console khi mất SSH, sai routing hoặc firewall tự khóa.
- Chạy các test phá hoại cần console/snapshot rollback.

## Việc assistant có thể làm trong workspace

Hiện chỉ có thể nghiên cứu và chuẩn bị kế hoạch vì `D:\Lab` chưa có repo. Sau khi user tạo repo hoặc cung cấp inventory, assistant có thể:

- Rà soát topology, IP plan và dependency graph.
- Thiết kế inventory Ansible, nhóm vùng và thứ tự bootstrap.
- Viết/kiểm tra policy schema, mapping 24 combo và test matrix.
- Kiểm tra cấu trúc playbook, idempotency, drift và các lệnh `make check`.
- Phân tích log, CSV test và bằng chứng sensor-vs-defender.
- Không thể tự bật VM, sửa VMware networking, cài phần mềm Windows hay xử lý console OPNsense.

## Giả định cần user xác nhận

1. Máy Hùng có đủ dung lượng SSD cho 12 VM, snapshot và WAL/PITR; RAM là giới hạn chính hiện tại.
2. VMware Workstation bản đang dùng hỗ trợ custom host-only networks cần thiết và multicast/VRRP theo thiết kế.
3. Windows host sẽ có adapter truy cập được từng vmnet; đây là điều kiện của ProxyJump.
4. Máy Bảo có quyền cài Tailscale, OpenSSH client và thay đổi WSL2.
5. Có thể giảm WSL2 từ 14 GB xuống trong lúc chạy lab.
6. Hai máy có cùng tailnet và Tailscale policy cho phép kết nối cần thiết.
7. `10.0.0.6` thực sự là nguồn quản trị được nhìn thấy từ OPNsense; nếu không, phải thay bằng alias nguồn đúng.
8. Mục tiêu chấp nhận NFR-13 ở mức phân tách logic, không yêu cầu độc lập vật lý.
9. Có thể dùng manual promote DB nếu automatic failover không đạt trong thời gian.
10. 14 test là mục tiêu kiểm chứng; không bắt buộc mọi test phải đạt nếu checkpoint ghi nhận hạ cấp trung thực.

**Phương án lười hơn:** trước mắt chỉ dựng một vertical slice `opns1 → lb1 → web1 → pg1`, xác nhận vmnet/ProxyJump/policy path trong một ngày; chỉ nhân bản thành HA và 12 VM khi slice này pass.

### Critical Files for Implementation
- `D:\Lab\ha-lb-security-lab.html`
- `D:\Lab\policy\zones.yml`
- `D:\Lab\ansible.cfg`
- `D:\Lab\inventory\hosts.yml`
- `D:\Lab\Makefile`

#### Thinking

**Planning detailed project documentation****Designing executable deployment runbook****Finalizing plan without repository changes**

#### Thinking

**Drafting detailed deployment plan****Specifying resource limits and file structure**

#### Thinking

**Planning role distinctions and phases****Designing WSL resource config recommendations**

#### Thinking

**Reviewing VMnet host adapter IP assignments**

Planner đã xác nhận critical path là `6 vmnet → SSH/ProxyJump → vertical slice`, không phải tạo đủ 12 VM trước. Mình bổ sung chi tiết địa chỉ quản trị và bảng cắt phạm vi trong tài liệu gốc trước khi ghi runbook, để không tự đoán IP nguồn hoặc hành vi failover.

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 117,
  "limit": 70,
  "pages": ""
}
```

**Response:**

117	<h3>2.2 Quyền truy cập từ máy Bảo</h3>
118	<pre>
119	# Liệt kê VM đang chạy và bật một VM từ xa
120	ssh hung@100.64.x.x '"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list'
121	ssh hung@100.64.x.x '"...\vmrun.exe" start "D:\lab\lb1\lb1.vmx" nogui'
122	
123	# Vào VM bất kỳ — dùng host làm jump hop
124	ssh -J hung@100.64.x.x ops@192.168.20.10          # lb1
125	ssh -J hung@100.64.x.x ops@192.168.30.11          # pg1
126	
127	# ansible.cfg — một dòng cho toàn bộ playbook
128	[ssh_connection]
129	ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o ProxyJump=hung@100.64.x.x
130	
131	# Giao diện đồ hoạ: port-forward, không cần route
132	ssh -L 3000:192.168.99.30:3000 hung@100.64.x.x    # Grafana   → http://localhost:3000
133	ssh -L 9090:192.168.99.30:9090 hung@100.64.x.x    # Prometheus
134	ssh -L 8443:192.168.99.100:443  hung@100.64.x.x   # GUI OPNsense (CARP VIP vùng MGMT)
135	ssh -L 8404:192.168.20.10:8404  hung@100.64.x.x   # HAProxy stats
136	</pre>
137	<p>
138	<strong>Bastion vẫn tồn tại trong lab</strong> (<code>obs</code>, 192.168.99.30, NIC MGMT). Bạn <em>không</em> đi qua nó để vào
139	lab nữa, nhưng nó vẫn là node mà POL-005 ("SSH chỉ từ MGMT") áp dụng, và vẫn là nơi chạy <code>repmgr witness</code> +
140	syslog receiver. Nhờ vậy ma trận chính sách không bị rỗng ở dòng SSH — nếu bỏ luôn bastion thì T-07 mất một nửa ý nghĩa.
141	</p>
142	
143	<h3>2.3 Thiết kế đã loại: vì sao trước đây cần cáp</h3>
144	<div class="stop">
145	Phiên bản v4.1 dùng 2 sợi cáp để <code>attacker</code>/<code>sensor</code>/<code>obs</code>/<code>ca</code> chạy trên máy Bảo.
146	Lý do phải dùng L2 thật: <strong>Tailscale không tạo broadcast domain chung giữa hai máy</strong> (mesh các <code>/32</code>),
147	nên VM trên máy Bảo không thể nằm cùng segment WAN với <code>opns1</code>.
148	<br><br>
149	Và đây là lý do <em>không được</em> nhân tiện đặt DMZ-FRONT lên cùng L2 với WAN — attacker đi vòng qua perimeter:
150	<pre>
151	ip route add 192.168.20.0/24 dev eth0
152	arping -I eth0 192.168.20.100          # lấy được MAC của VIP
153	curl -k --resolve lab:443:192.168.20.100 https://lab/    # KHÔNG đi qua firewall
154	</pre>
155	Giữ lại đoạn này trong báo cáo như một <em>rejected design</em>: nó giải thích vì sao DMZ thật phải là VLAN/L2 riêng,
156	và vì sao ta chọn "mọi thứ trong một host, các vùng là vmnet tách biệt" thay vì "hai máy nối cáp".
157	</div>
158	
159	<h3>2.4 Bảy điều bắt buộc lưu ý khi dùng Tailscale</h3>
160	<table>
161	    <tr><th>#</th><th>Lưu ý</th><th>Chi tiết / lệnh</th></tr>
162	    <tr><td>1</td><td><strong>Tắt hạn key</strong></td>
163	        <td>Mặc định Tailscale hết hạn key sau 180 ngày. Hai máy chạy từ trước kỳ học → <em>giữa kỳ bị đá khỏi tailnet</em>,
164	        và thông báo rất khó đoán. <code>tailscale set --expiry=0</code> trên cả hai máy, ghi vào <code>docs/interfaces.md</code>.</td></tr>
165	    <tr><td>2</td><td><strong>Không advertise routes</strong></td>
166	        <td>Đừng chạy <code>--advertise-routes=192.168.20.0/24,...</code> và đừng cố bật IP forwarding trên Windows.
167	        ProxyJump + <code>-L</code> đã đủ mọi nhu cầu. Đây là hố thời gian lớn nhất của phương án này.</td></tr>
168	    <tr><td>3</td><td><strong>OpenSSH Server, không phải Tailscale SSH, cho vai jump</strong></td>
169	        <td>Tailscale SSH tiện để login nhưng hỗ trợ <code>-W</code>/ProxyJump không ổn định. Cài <code>sshd</code> Windows,
170	        StartupType Automatic, key-only.</td></tr>
171	    <tr><td>4</td><td><strong>Biết mình đang direct hay DERP</strong></td>
172	        <td>Cùng một LAN → kết nối trực tiếp, độ trễ &lt;1 ms, gần bằng cáp. Khác mạng → có thể đi qua DERP (rẽ qua Internet),
173	        latency nhảy. Trước mỗi phép đo timing: <code>tailscale status | grep &lt;bạn&gt;</code>, và ghi <code>direct</code>/<code>DERP</code> vào biên bản test.</td></tr>
174	    <tr><td>5</td><td><strong>Mất Internet = mất điều khiển từ xa</strong></td>
175	        <td>Không có fallback nào ngoài việc sang máy Hùng làm trực tiếp. Vì vậy: việc quan trọng luôn có lệnh thủ công tương đương,
176	        và không có việc nào chỉ chạy được từ máy Bảo.</td></tr>
177	    <tr><td>6</td><td><strong>Máy Hùng là điểm nghẽn tiến độ</strong></td>
178	        <td>Hùng tắt máy thì Bảo chỉ viết code/báo cáo. Quy ước: thông báo trước 1 ngày khi cần lab bật; phần việc của Bảo trong
179	        khung không có lab chuyển sang B04/B18 (policy YAML, báo cáo).</td></tr>
180	    <tr><td>7</td><td><strong>Đường quản trị không qua firewall — phải nói rõ</strong></td>
181	        <td>Đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter.
182	        Ghi thẳng vào báo cáo (B10) thay vì để giám khảo phát hiện; nếu không, nó trông như một lỗ hổng bạn không biết mình có.</td></tr>
183	</table>
184	
185	<h3>2.5 Cái được và cái mất so với phương án 2 cáp</h3>
186	<table>

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 718,
  "limit": 55,
  "pages": ""
}
```

**Response:**

718	<h2>11. Bảng cắt khẩn cấp (kích hoạt ở Checkpoint 1 hoặc 2)</h2>
719	<table>
720	    <tr><th>Thứ tự</th><th>Cắt</th><th>Giờ giữ lại</th><th>Độ khó sau cắt</th></tr>
721	    <tr><td>1</td><td>H10 state limit + SYN flood</td><td>2</td><td>Perimeter 4.5 → 4.3</td></tr>
722	    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
723	    <tr><td>3</td><td>B14 phần đối chiếu sensor-vs-defender (chỉ dùng log phòng thủ)</td><td>3</td><td>Attack validation 4.2 → 3.9</td></tr>
724	    <tr><td>4</td><td>H09 test fail-closed (chuyển thành mô tả thiết kế + lý do)</td><td>2</td><td>IPS 4.6 → 4.3</td></tr>
725	    <tr><td>5</td><td>H08 CRS xuống DetectionOnly + còn 10 payload</td><td>2</td><td>WAF 4.2 → 3.6 ⚠</td></tr>
726	    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
727	    <tr><td colspan="2"><strong>TUYỆT ĐỐI KHÔNG CẮT</strong></td>
728	        <td colspan="2">H03 (CARP + pfsync), B06 (policy-as-code + apply không gián đoạn), H05 (IPS blocking),
729	        B07 (ma trận chính sách) — bốn thứ định danh bản v4. Cắt một trong bốn thì nên nộp bản v3.</td></tr>
730	</table>
731	
732	<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
733	<table>
734	    <tr><th>Rủi ro</th><th>Phòng ngừa</th></tr>
735	    <tr><td><strong>Tailscale hết hạn key sau 180 ngày</strong> → giữa kỳ học hai máy mất nhau, thông báo lại rất ít ngữ cảnh</td>
736	        <td>Chạy <code>tailscale set --expiry=0</code> trên cả hai máy <em>ngay ngày 1</em>, và ghi vào <code>docs/interfaces.md</code></td></tr>
737	    <tr><td>Cố bật <code>--advertise-routes</code> + IP forwarding trên Windows để "route vào VM"</td>
738	        <td><strong>Đừng.</strong> Chỉ dùng ProxyJump và <code>-L</code>: host đã có adapter trên từng vmnet nên nó tới được mọi VM mà không cần route. Đây là hố 2 giờ đã được ghi nhận</td></tr>
739	    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
740	    <tr><td>Mất Internet là mất quyền điều khiển lab</td>
741	        <td>Khi hai máy <em>cùng một mạng LAN</em>, Tailscale tự kết nối trực tiếp (không qua DERP) nên gần như không rủi ro.
742	        Khi ở khác mạng, luôn <code>tailscale status</code> xem là <code>direct</code> hay <code>DERP</code>; đang DERP mà chạy test timing thì ghi rõ vào biên bản</td></tr>
743	    <tr><td>Máy Hùng là điểm nghẽn: Hùng tắt máy thì Bảo không làm gì được ngoài viết code</td>
744	        <td>Quy ước giờ trực: Hùng bật lab trong khung Bảo cần (thông báo trước 1 ngày); phần việc của Bảo ngày đó chuyển sang B04/B18</td></tr>
745	    <tr><td>Đường quản trị không đi qua firewall → dễ bị hỏi "anh kiểm soát admin path thế nào"</td>
746	        <td>B10: viết rõ đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter,
747	        và bastion trong MGMT vẫn tồn tại để POL-005 còn ý nghĩa</td></tr>
748	    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
749	        <td>Ngày 5 <code>curl</code> thử 3 endpoint trước khi viết playbook; khoá <strong>cùng một phiên bản</strong> cho cả 2 con opns; luôn có phương án B</td></tr>
750	    <tr><td>cfgsync ghi đè cấu hình đang làm dở</td><td>Tắt auto-sync khi làm việc, chỉ sync khi chủ động; snapshot trước mỗi lần sync</td></tr>
751	    <tr><td>IPS inline làm sập kết nối ngay buổi demo</td><td>Nút tắt IPS trong 1 lệnh + snapshot <code>IPS-off</code>; test fail-closed ở ngày 9 chứ không phải ngày 14</td></tr>
752	    <tr><td>Hai người cùng sửa rule</td><td>Chỉ Bảo sửa <code>policy/*.yml</code>; Hùng chỉ chạy playbook; sửa trên GUI bị <code>make drift</code> bắt</td></tr>
753	    <tr><td>Lệch đồng hồ làm PITR và đối chiếu log sai</td><td>Một source NTP cho 12 VM + 2 host OS; kiểm <code>date</code> trước mỗi lần đo</td></tr>
754	</table>
755	
756	<h2>13. Sáu mươi phút đầu tiên — làm đủ rồi mới chia việc</h2>
757	<ol>
758	    <li>Cài VMware Workstation Pro trên máy Hùng (bản miễn phí cho cá nhân). Máy Bảo chỉ cần Tailscale + trình duyệt + WSL2.</li>
759	    <li>Cài Tailscale trên <strong>cả hai máy</strong>, đăng nhập cùng tailnet, chạy <code>tailscale set --expiry=0</code> mỗi máy.
760	        Ghi lại IP của nhau vào <code>docs/interfaces.md</code>.</li>
761	    <li>Trên máy Hùng: bật OpenSSH Server (<code>Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0</code>,
762	        <code>Start-Service sshd</code>, đặt StartupType Automatic). Kiểm từ máy Bảo: <code>ssh hung@&lt;tailscale-ip&gt; hostname</code>.</li>
763	    <li>Tạo <strong>1 VM Debian</strong> trên vmnet bất kỳ, rồi kiểm điều kiện quyết định của cả phương án này:
764	        <code>ssh -J hung@&lt;tailscale-ip&gt; ops@&lt;ip-VM&gt;</code>. Thông thì toàn bộ quyền điều khiển từ xa đã solved, không cần cáp.</li>
765	    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
766	        <strong>bước này quyết định 15 giờ làm việc của B06/B07</strong>.</li>
767	    <li>Tạo 2 VM OPNsense trên cùng <code>vmnet-sync</code>, cấu hình CARP 1 vhid, xác nhận <code>ifconfig carp</code> báo MASTER/BACKUP
768	        và <code>tcpdump -i vmnet-sync proto 24</code> thấy pfsync.</li>
769	    <li>Tạo 1 VM Debian thứ hai trên cùng segment, bật promiscuous, xác nhận <code>tcpdump</code> bắt được traffic của VM khác
770	        (đây là cơ chế hoạt động của <code>sensor</code>).</li>
771	    <li>Bước 4 trượt → dừng ngay, quay về mô hình "hai người ngồi chung một máy" (vẫn đủ 14 kịch bản, chỉ mất quyền làm việc từ xa).
772	        Bước 5 hoặc 6 trượt → dành tối đa 2 giờ, sau đó kích hoạt phương án B cho renderer hoặc ghi sensor vào <code>attacker</code>.</li>

#### Tool: Read

**Input:**

```json
{
  "file_path": "D:\\Lab\\ha-lb-security-lab.html",
  "offset": 720,
  "limit": 100,
  "pages": ""
}
```

**Response:**

720	    <tr><th>Thứ tự</th><th>Cắt</th><th>Giờ giữ lại</th><th>Độ khó sau cắt</th></tr>
721	    <tr><td>1</td><td>H10 state limit + SYN flood</td><td>2</td><td>Perimeter 4.5 → 4.3</td></tr>
722	    <tr><td>2</td><td>Gộp <code>sensor</code> vào <code>attacker</code> (1 VM, vẫn capture trên vmnet riêng)</td><td>1.5</td><td>Attack validation 4.2 → 4.1 (rẻ, ít mất)</td></tr>
723	    <tr><td>3</td><td>B14 phần đối chiếu sensor-vs-defender (chỉ dùng log phòng thủ)</td><td>3</td><td>Attack validation 4.2 → 3.9</td></tr>
724	    <tr><td>4</td><td>H09 test fail-closed (chuyển thành mô tả thiết kế + lý do)</td><td>2</td><td>IPS 4.6 → 4.3</td></tr>
725	    <tr><td>5</td><td>H08 CRS xuống DetectionOnly + còn 10 payload</td><td>2</td><td>WAF 4.2 → 3.6 ⚠</td></tr>
726	    <tr><td>6</td><td>H12 PITR xuống full-restore (mất khôi phục theo timestamp)</td><td>2</td><td>4.5 → 3.9 ⚠</td></tr>
727	    <tr><td colspan="2"><strong>TUYỆT ĐỐI KHÔNG CẮT</strong></td>
728	        <td colspan="2">H03 (CARP + pfsync), B06 (policy-as-code + apply không gián đoạn), H05 (IPS blocking),
729	        B07 (ma trận chính sách) — bốn thứ định danh bản v4. Cắt một trong bốn thì nên nộp bản v3.</td></tr>
730	</table>
731	
732	<h2>12. Rủi ro riêng của bố trí "một máy host + Tailscale"</h2>
733	<table>
734	    <tr><th>Rủi ro</th><th>Phòng ngừa</th></tr>
735	    <tr><td><strong>Tailscale hết hạn key sau 180 ngày</strong> → giữa kỳ học hai máy mất nhau, thông báo lại rất ít ngữ cảnh</td>
736	        <td>Chạy <code>tailscale set --expiry=0</code> trên cả hai máy <em>ngay ngày 1</em>, và ghi vào <code>docs/interfaces.md</code></td></tr>
737	    <tr><td>Cố bật <code>--advertise-routes</code> + IP forwarding trên Windows để "route vào VM"</td>
738	        <td><strong>Đừng.</strong> Chỉ dùng ProxyJump và <code>-L</code>: host đã có adapter trên từng vmnet nên nó tới được mọi VM mà không cần route. Đây là hố 2 giờ đã được ghi nhận</td></tr>
739	    <tr><td>Dùng Tailscale SSH làm jump hop</td><td>Cài OpenSSH Server trên Windows của Hùng cho vai jump; Tailscale SSH hỗ trợ <code>-W</code> không ổn định bằng</td></tr>
740	    <tr><td>Mất Internet là mất quyền điều khiển lab</td>
741	        <td>Khi hai máy <em>cùng một mạng LAN</em>, Tailscale tự kết nối trực tiếp (không qua DERP) nên gần như không rủi ro.
742	        Khi ở khác mạng, luôn <code>tailscale status</code> xem là <code>direct</code> hay <code>DERP</code>; đang DERP mà chạy test timing thì ghi rõ vào biên bản</td></tr>
743	    <tr><td>Máy Hùng là điểm nghẽn: Hùng tắt máy thì Bảo không làm gì được ngoài viết code</td>
744	        <td>Quy ước giờ trực: Hùng bật lab trong khung Bảo cần (thông báo trước 1 ngày); phần việc của Bảo ngày đó chuyển sang B04/B18</td></tr>
745	    <tr><td>Đường quản trị không đi qua firewall → dễ bị hỏi "anh kiểm soát admin path thế nào"</td>
746	        <td>B10: viết rõ đây là <em>out-of-band management</em> (tương đương console/IPMI), nằm ngoài phạm vi chính sách perimeter,
747	        và bastion trong MGMT vẫn tồn tại để POL-005 còn ý nghĩa</td></tr>
748	    <tr><td>API OPNsense đổi tên endpoint theo phiên bản → renderer viết xong không chạy</td>
749	        <td>Ngày 5 <code>curl</code> thử 3 endpoint trước khi viết playbook; khoá <strong>cùng một phiên bản</strong> cho cả 2 con opns; luôn có phương án B</td></tr>
750	    <tr><td>cfgsync ghi đè cấu hình đang làm dở</td><td>Tắt auto-sync khi làm việc, chỉ sync khi chủ động; snapshot trước mỗi lần sync</td></tr>
751	    <tr><td>IPS inline làm sập kết nối ngay buổi demo</td><td>Nút tắt IPS trong 1 lệnh + snapshot <code>IPS-off</code>; test fail-closed ở ngày 9 chứ không phải ngày 14</td></tr>
752	    <tr><td>Hai người cùng sửa rule</td><td>Chỉ Bảo sửa <code>policy/*.yml</code>; Hùng chỉ chạy playbook; sửa trên GUI bị <code>make drift</code> bắt</td></tr>
753	    <tr><td>Lệch đồng hồ làm PITR và đối chiếu log sai</td><td>Một source NTP cho 12 VM + 2 host OS; kiểm <code>date</code> trước mỗi lần đo</td></tr>
754	</table>
755	
756	<h2>13. Sáu mươi phút đầu tiên — làm đủ rồi mới chia việc</h2>
757	<ol>
758	    <li>Cài VMware Workstation Pro trên máy Hùng (bản miễn phí cho cá nhân). Máy Bảo chỉ cần Tailscale + trình duyệt + WSL2.</li>
759	    <li>Cài Tailscale trên <strong>cả hai máy</strong>, đăng nhập cùng tailnet, chạy <code>tailscale set --expiry=0</code> mỗi máy.
760	        Ghi lại IP của nhau vào <code>docs/interfaces.md</code>.</li>
761	    <li>Trên máy Hùng: bật OpenSSH Server (<code>Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0</code>,
762	        <code>Start-Service sshd</code>, đặt StartupType Automatic). Kiểm từ máy Bảo: <code>ssh hung@&lt;tailscale-ip&gt; hostname</code>.</li>
763	    <li>Tạo <strong>1 VM Debian</strong> trên vmnet bất kỳ, rồi kiểm điều kiện quyết định của cả phương án này:
764	        <code>ssh -J hung@&lt;tailscale-ip&gt; ops@&lt;ip-VM&gt;</code>. Thông thì toàn bộ quyền điều khiển từ xa đã solved, không cần cáp.</li>
765	    <li>Tạo 1 VM OPNsense, bật API, <code>curl /api/firewall/alias/searchAlias</code> xem có trả JSON hợp lệ —
766	        <strong>bước này quyết định 15 giờ làm việc của B06/B07</strong>.</li>
767	    <li>Tạo 2 VM OPNsense trên cùng <code>vmnet-sync</code>, cấu hình CARP 1 vhid, xác nhận <code>ifconfig carp</code> báo MASTER/BACKUP
768	        và <code>tcpdump -i vmnet-sync proto 24</code> thấy pfsync.</li>
769	    <li>Tạo 1 VM Debian thứ hai trên cùng segment, bật promiscuous, xác nhận <code>tcpdump</code> bắt được traffic của VM khác
770	        (đây là cơ chế hoạt động của <code>sensor</code>).</li>
771	    <li>Bước 4 trượt → dừng ngay, quay về mô hình "hai người ngồi chung một máy" (vẫn đủ 14 kịch bản, chỉ mất quyền làm việc từ xa).
772	        Bước 5 hoặc 6 trượt → dành tối đa 2 giờ, sau đó kích hoạt phương án B cho renderer hoặc ghi sensor vào <code>attacker</code>.</li>
773	</ol>
774	
775	</body>
776	</html>
777

#### Thinking

**Planning step-by-step project deployment in Vietnamese****Creating detailed step-by-step deployment plan document****Defining concrete plan steps with explicit commands**

#### Thinking

**Planning variable substitution strategy****Defining variable usage and user action boundaries****Planning phased task updates with user approval**

Mình sẽ viết runbook vào `docs/superpowers/plans/` với 7 phase, lộ trình 14 ngày, checkpoint, lệnh cụ thể và bảng phân quyền. Phần có thể làm tự động sẽ được đánh dấu rõ; mọi bước có quyền admin, secret, GUI VMware, console hoặc nguy cơ làm mất kết nối sẽ yêu cầu bạn thao tác và xác nhận.

#### Thinking

**Outlining HA/LB Security Lab Deployment Plan****Finalizing WSL Resource Allocation Constraints**

#### Thinking

**Planning WSL resource optimization options****Defining phased implementation plan and file structure**

#### Thinking

**Detailing Windows OpenSSH setup commands****Clarifying SSH key locations and VMware network setup**

#### Thinking

**Clarifying sync IP address plan****Defining OPNsense IPs and resource profiles**

#### Thinking

**Planning WSL shutdown and verification steps****Designing phased test plan with user roles****Outlining detailed day schedule and tasks**

#### Thinking

**Planning detailed runbook structure****Enforcing absolute path Markdown links**

#### Tool: Write

**Input:**

```json
{
  "file_path": "D:\\Lab\\docs\\superpowers\\plans\\2026-11-07-ha-lb-security-lab-deployment.md",
  "content": "# HA/LB Security Lab Deployment Plan\n\n> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.\n\n**Goal:** Dựng lab 12 VM firewall/security-first trên một máy Windows + VMware, dùng WSL2 như control plane nhẹ, đạt các checkpoint HA, policy-as-code, IPS, dịch vụ, khôi phục và kiểm thử tấn công trong phạm vi mạng riêng.\n\n**Architecture:** Windows giữ VMware Workstation, sáu mạng host-only và toàn bộ VM; WSL2 chỉ giữ Git, Ansible, validator và script kiểm thử. Máy điều khiển từ xa đi qua Tailscale tới Windows OpenSSH rồi dùng ProxyJump/port-forward; không advertise route và không bật IP forwarding trên Windows. Lab được dựng theo vertical slice trước, sau đó mới nhân bản thành 12 VM.\n\n**Tech Stack:** Windows 11 Pro, WSL2, một distro Linux duy nhất cho control plane, Git, Python, Ansible, OpenSSH, Tailscale, VMware Workstation Pro, OPNsense, Debian 12, HAProxy, Keepalived, PostgreSQL 16, repmgr, pgBackRest, Suricata, Apache/mod_security2, step-ca, rsyslog/Loki, Prometheus/Grafana, Zeek và tcpdump.\n\n**Spec:** `D:\\Lab\\ha-lb-security-lab.html`\n\n## Global Constraints\n\n- Chạy mọi VM trên mạng VMware host-only/private; không dùng bridged cho lab và không để attacker có đường L2 trực tiếp tới DMZ.\n- WSL2 là control plane, không chạy nested VM, database, Docker/Podman hoặc workload lab lâu dài trong WSL.\n- Hạ giới hạn WSL2 từ cấu hình hiện tại `14 GB RAM / 10 vCPU / 16 GB swap` xuống profile phù hợp khi VMware chạy; mục tiêu ban đầu là `6 GB RAM / 4 vCPU / 4-8 GB swap`.\n- Không bật đồng thời cả 12 VM cho tới khi profile tài nguyên và vertical slice đã pass.\n- Không đoán IP quản trị. Tailscale IP, IP nguồn thật của Windows host và endpoint API OPNsense phải được lấy từ môi trường thực tế rồi ghi vào `docs/interfaces.md`.\n- Không đưa API key, secret, private key, certificate private material hoặc password vào Git, chat hoặc file log.\n- Chỉ chạy attack/flood test từ VM attacker trên vmnet private đã xác nhận; không bridged, không nhắm tới hệ thống ngoài lab.\n- Snapshot trước mỗi thay đổi HA/IPS/failover và trước mỗi test có thể làm mất kết nối.\n- Mốc bắt buộc không được cắt trong bản v4: CARP+pfsync, policy-as-code, IPS blocking và ma trận policy 24 combo.\n- Nếu một checkpoint fail, dừng tại checkpoint đó; không xây thêm tầng phụ thuộc lên nền đang hỏng.\n- Tài liệu phải ghi trung thực NFR-13 là phân tách logic trên cùng một host vật lý, không trình bày như độc lập vật lý.\n\n## Phạm vi trách nhiệm\n\n### Assistant có thể làm trong workspace\n\n- Tạo và kiểm tra cấu trúc repo, inventory, policy YAML, schema, Ansible roles/playbooks, Makefile và script kiểm thử.\n- Viết validator policy, ma trận 24 combo, drift check, `run_matrix.sh`, parser CSV và báo cáo.\n- Rà soát idempotency, quoting, SSH ProxyJump, secret handling và lệnh `make check`.\n- Phân tích output do user cung cấp, log, CSV, packet capture metadata và ảnh checkpoint.\n- Chuẩn bị lệnh PowerShell/WSL/SSH có thể copy-paste, nhưng không tự ý chạy lệnh thay đổi hệ thống.\n- Có thể chạy kiểm tra read-only trên máy hiện tại nếu user muốn; mọi thao tác cần quyền admin, mạng, cài package, restart WSL/VM hoặc thay đổi firewall phải được user xác nhận trước.\n\n### User phải tự làm hoặc phải xác nhận trực tiếp\n\n- Đăng nhập/cấu hình Tailscale, cấp quyền tailnet, tắt key expiry theo policy và thao tác trên máy thứ hai.\n- Cài/bật OpenSSH Server Windows, Windows Firewall, VMware Workstation, VMnet và driver/network adapter.\n- Tạo VM, gắn NIC, cài OS/OPNsense, đặt password/key ban đầu, snapshot và thao tác console khi SSH bị khóa.\n- Tạo API key/secret, CA private key, database password và lưu chúng trong secret store cục bộ.\n- Điều chỉnh `.wslconfig`, chạy `wsl --shutdown`, reboot Windows hoặc thay đổi pagefile/power plan.\n- Xác nhận VMware multicast/VRRP, promiscuous capture và hành vi failover bằng console/GUI.\n- Chạy test phá hoại: dừng Suricata, kill PostgreSQL, cắt vmnet-sync, SYN test và rollback snapshot.\n- Quyết định chấp nhận trade-off khi checkpoint fail hoặc khi phải cắt phạm vi.\n\n### Cách phối hợp\n\n- User hoàn thành từng bước được đánh dấu **USER**, gửi output đã loại secret.\n- Assistant kiểm tra output, tạo hoặc sửa artifact được đánh dấu **ASSISTANT**, rồi trả lại bước kế tiếp.\n- Bước **TOGETHER** chỉ được coi là xong khi hai bên cùng xem kết quả và ghi checkpoint.\n- Không gửi raw output chứa token/private key. Với API, chỉ gửi HTTP status, endpoint path, field names và lỗi đã che giá trị.\n\n## File structure sau khi khởi tạo repo\n\nCác file dưới đây chưa tồn tại trong workspace tại thời điểm lập kế hoạch. Chỉ tạo chúng sau khi Phase 0 và Phase 1 pass.\n\n- `README.md` — mục tiêu, topology, cách khởi động/tắt lab và cảnh báo an toàn.\n- `.gitignore` — loại secret, certificate issued, state, cache, capture và artifact lớn.\n- `.gitleaks.toml` — luật secret scan tối thiểu.\n- `Makefile` — các entrypoint `check`, `policy-lint`, `drift`, `access-check`, `matrix`, `report`.\n- `ansible.cfg` — inventory, SSH ProxyJump, control persistence, timeout và host key policy.\n- `inventory/hosts.yml` — nhóm `opnsense`, `lb`, `web`, `postgres`, `obs`, `ca`, `attacker`, `sensor` và zone.\n- `inventory/group_vars/all.yml` — IP không nhạy cảm, tên zone, port, feature flags và đường dẫn artifact.\n- `inventory/group_vars/vault.example.yml` — tên biến secret, không chứa giá trị.\n- `policy/zones.yml` — nguồn chân lý cho zone, alias, rule, NAT, test mapping và reason.\n- `policy/schema.yml` — schema/constraint cho policy YAML.\n- `roles/opnsense_policy/` — renderer/apply policy qua API sau khi đã xác nhận endpoint.\n- `roles/haproxy/`, `roles/keepalived/`, `roles/web/`, `roles/postgres/`, `roles/observability/` — cấu hình dịch vụ từng tầng.\n- `playbooks/bootstrap.yml` — bootstrap Linux VM không phá hủy.\n- `playbooks/apply_policy.yml` — validate, diff, apply và post-check policy.\n- `playbooks/services.yml` — HAProxy, web, PostgreSQL, observability và CA.\n- `scripts/verify_access.sh` — kiểm ProxyJump, port-forward, `vmrun` và vùng mạng.\n- `scripts/validate_policy.py` — kiểm schema, alias, rule ID và 24 combo.\n- `scripts/run_matrix.sh` — chạy test theo schema CSV đã định nghĩa.\n- `scripts/report.py` — tổng hợp CSV, pass/fail, RTO/RPO và biểu đồ tối thiểu.\n- `tests/test_policy_schema.py` — self-check cho schema và rule invariant.\n- `tests/test_matrix_schema.py` — self-check cho output test.\n- `docs/interfaces.md` — mapping VMnet, IP, Tailscale, SSH jump, phiên bản và ngày xác nhận.\n- `docs/checkpoints.md` — biên bản P0-P6, người xác nhận và bằng chứng.\n- `docs/runbooks/` — thao tác user trên Windows/VMware/OPNsense và rollback.\n- `docs/evidence/` — chỉ metadata/link tới artifact; không commit secret hoặc capture lớn.\n\n---\n\n## Task 0: Chuẩn bị an toàn và chốt điều kiện máy chủ\n\n**Owner:** USER, có ASSISTANT hướng dẫn và kiểm tra output.\n\n**Mục tiêu:** Xác nhận máy đủ chỗ cho WSL control plane + VMware core profile, tạo đường rollback trước khi chỉnh tài nguyên.\n\n**Không tạo VM hoặc cài package ở task này.**\n\n- [ ] **Step 0.1: Đóng các workload không cần thiết.**\n\n  User đóng IDE/browser/process nặng trên Windows, không đóng VMware nếu đang có lab khác cần giữ. Ghi lại các VM ngoài phạm vi nếu có.\n\n- [ ] **Step 0.2: Ghi baseline tài nguyên.**\n\n  Chạy PowerShell thường:\n\n  ```powershell\n  Get-CimInstance Win32_ComputerSystem |\n    Select-Object Manufacturer,Model,TotalPhysicalMemory\n  Get-CimInstance Win32_Processor |\n    Select-Object Name,NumberOfCores,NumberOfLogicalProcessors\n  Get-Counter '\\Memory\\Available MBytes','\\Memory\\Committed Bytes','\\Memory\\Commit Limit' |\n    Select-Object -ExpandProperty CounterSamples |\n    Format-Table Path,CookedValue -AutoSize\n  Get-Volume | Where-Object DriveLetter |\n    Select-Object DriveLetter,FileSystem,Size,SizeRemaining,HealthStatus\n  Get-Process vmware*,vmx*,vmmem* -ErrorAction SilentlyContinue |\n    Select-Object ProcessName,Id,WorkingSet64,PrivateMemorySize64\n  ```\n\n  User gửi lại số liệu, không cần gửi username, token hoặc đường dẫn private khác.\n\n- [ ] **Step 0.3: Sao lưu cấu hình WSL hiện tại.**\n\n  User thực hiện:\n\n  ```powershell\n  Copy-Item \"$env:USERPROFILE\\.wslconfig\" `\n    \"$env:USERPROFILE\\.wslconfig.before-ha-lab-2026-11-07\"\n  ```\n\n  Nếu file chưa tồn tại thì bỏ qua lệnh `Copy-Item` và báo lại.\n\n- [ ] **Step 0.4: Chọn WSL profile chạy lab.**\n\n  Assistant sẽ review baseline rồi đề xuất giá trị cuối. Giá trị mặc định để bắt đầu là:\n\n  ```ini\n  [wsl2]\n  memory=6GB\n  processors=4\n  swap=8GB\n  nestedVirtualization=false\n  guiApplications=false\n  networkingMode=nat\n  localhostForwarding=true\n\n  [experimental]\n  sparseVhd=true\n  autoMemoryReclaim=dropcache\n  ```\n\n  Không tự ghi đè file hiện tại. User chỉ sửa sau khi xác nhận profile và hiểu rằng WSL GUI/nested VM sẽ không còn là mục tiêu của lab.\n\n- [ ] **Step 0.5: Áp dụng profile và kiểm tra WSL.**\n\n  Sau khi user xác nhận, user chạy:\n\n  ```powershell\n  wsl.exe --shutdown\n  wsl.exe --status\n  wsl.exe --list --verbose\n  ```\n\n  Mở đúng một distro control plane sau đó kiểm tra:\n\n  ```powershell\n  wsl.exe -d Ubuntu-26.04 -- sh -lc 'nproc; free -h; df -hT /'\n  ```\n\n  Nếu distro control plane chưa được chọn, dừng và chọn một distro duy nhất; không cài Ansible vào cả Kali, Arch và Ubuntu.\n\n- [ ] **Step 0.6: Chốt distro control plane.**\n\n  Khuyến nghị dùng Ubuntu 26.04 cho Ansible/Python. Arch chỉ giữ cho mục đích riêng; Kali chỉ dùng nếu cần tool attack và chỉ bật khi test. Không dùng Kali làm control plane chính.\n\n**Pass P0:** WSL khởi động với giới hạn mới, còn ít nhất khoảng 8 GB headroom khi chưa chạy VM, ổ D còn đủ chỗ cho 12 VM/snapshot/WAL, và có bản sao `.wslconfig`.\n\n**Fail P0:** Không tạo VM. Assistant giúp tính lại profile hoặc đề xuất vertical slice 4-6 VM. Nếu host đã có workload khác chiếm RAM, user phải giải phóng hoặc chấp nhận chạy lab theo ca.\n\n---\n\n## Task 1: Tạo đường điều khiển từ xa và go/no-go trong 60 phút\n\n**Owner:** USER trên Windows và máy thứ hai; ASSISTANT chuẩn bị file/checklist sau khi kết quả có thật.\n\n**Mục tiêu:** Chứng minh `máy điều khiển -> Tailscale -> Windows OpenSSH -> ProxyJump -> VM Linux` trước khi đầu tư vào 12 VM.\n\n- [ ] **Step 1.1: Bật Tailscale trên hai máy.**\n\n  User cài/đăng nhập Tailscale bằng tài khoản tailnet của họ. Trên từng máy chạy:\n\n  ```powershell\n  tailscale ip -4\n  tailscale status\n  tailscale set --expiry=0\n  tailscale status\n  ```\n\n  Nếu tailnet policy không cho `--expiry=0`, user ghi rõ policy và thời hạn thực tế; không cố bypass. Không chạy `--advertise-routes`.\n\n- [ ] **Step 1.2: Bật Windows OpenSSH Server trên máy host VMware.**\n\n  Mở PowerShell **Run as Administrator** trên máy host:\n\n  ```powershell\n  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0\n  Start-Service sshd\n  Set-Service -Name sshd -StartupType Automatic\n  Get-Service sshd\n  Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue\n  ```\n\n  Nếu capability đã có, chỉ cần start service và đặt startup. Không mở port SSH ra Wi-Fi/public interface ngoài rule cần thiết cho Tailscale.\n\n- [ ] **Step 1.3: Cấu hình SSH key-only an toàn.**\n\n  User tạo public key ở máy điều khiển nếu chưa có, chép **public key** vào authorized keys trên Windows host, thử login bằng key trước rồi mới tắt password authentication. Không gửi private key cho assistant.\n\n  Kiểm tra từ máy điều khiển:\n\n  ```bash\n  ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no <windows-user>@<tailscale-ip> hostname\n  ```\n\n  `<windows-user>` và `<tailscale-ip>` phải lấy từ output thật; không đoán hoặc commit vào repo.\n\n- [ ] **Step 1.4: Tạo một VM Debian smoke-test.**\n\n  User tạo một VM Debian 12 duy nhất, một NIC trên bất kỳ vmnet private tạm thời, IP tĩnh trong subnet đó, SSH key-only và user `ops`. Chưa cài ứng dụng.\n\n- [ ] **Step 1.5: Kiểm ProxyJump từ máy điều khiển và từ WSL.**\n\n  Từ máy điều khiển:\n\n  ```bash\n  ssh -J <windows-user>@<tailscale-ip> ops@<debian-smoke-ip> hostname\n  ```\n\n  Từ WSL control plane:\n\n  ```bash\n  ssh -J <windows-user>@<tailscale-ip> ops@<debian-smoke-ip> hostname\n  ```\n\n  User ghi kết quả `direct` hoặc `DERP` từ `tailscale status`; không dùng kết quả DERP cho benchmark timing.\n\n- [ ] **Step 1.6: Kiểm đường điều khiển VM bằng `vmrun`.**\n\n  Từ máy điều khiển hoặc WSL gọi qua Windows SSH, user kiểm tra:\n\n  ```bash\n  ssh <windows-user>@<tailscale-ip> '\"C:\\Program Files (x86)\\VMware\\VMware Workstation\\vmrun.exe\" list'\n  ```\n\n  Chỉ chạy `start`/`stop` sau khi user xác nhận đúng đường dẫn `.vmx`; không dùng wildcard.\n\n- [ ] **Step 1.7: Ghi interface map tạm thời.**\n\n  Assistant tạo `docs/interfaces.md` sau khi nhận các giá trị đã che secret. File phải ghi hostname, Tailscale IP, vmnet mapping, Linux VM IP, phiên bản VMware/OPNsense/Debian và thời điểm xác nhận.\n\n**Pass P1:** SSH vào Windows host bằng key, ProxyJump vào Debian smoke-test từ WSL, và `vmrun list` trả kết quả đúng.\n\n**Fail P1:** Dừng. Chọn một trong hai phương án:\n\n1. Hai người thao tác trực tiếp trên máy VMware host, giữ nguyên lab 14 test nhưng bỏ remote control.\n2. Sửa Windows OpenSSH/Tailscale/VMnet rồi lặp lại tối đa 60 phút.\n\nKhông dựng 12 VM khi P1 chưa pass.\n\n---\n\n## Task 2: Tạo sáu mạng VMware và IP plan\n\n**Owner:** USER trên VMware GUI; ASSISTANT kiểm tra mapping và tính nhất quán.\n\n**Mục tiêu:** Tạo topology L2 đúng trước khi cài dịch vụ.\n\n- [ ] **Step 2.1: Mở Virtual Network Editor với quyền admin.**\n\n  User tạo sáu custom host-only/private network. Tên nội bộ VMware có thể là VMnet2-VMnet7; tên logic trong repo phải theo bảng này:\n\n  | Logic | Subnet | DHCP | Host adapter | Dùng cho |\n  |---|---|---|---|---|\n  | `wan` | `10.0.0.0/24` | Off | On | OPNsense WAN, attacker, sensor |\n  | `sync` | `192.168.50.0/24` | Off | Optional/on nếu cần debug | pfsync/cfgsync chỉ giữa OPNsense |\n  | `dmz_front` | `192.168.20.0/24` | Off | On | LB và OPNsense |\n  | `dmz_app` | `192.168.21.0/24` | Off | On | web và OPNsense |\n  | `trusted` | `192.168.30.0/24` | Off | On | PostgreSQL và OPNsense |\n  | `mgmt` | `192.168.99.0/24` | Off | On | OPNsense GUI, obs, ca |\n\n  Không bật NAT hoặc bridged. Không dùng cùng một VMnet cho WAN và DMZ.\n\n- [ ] **Step 2.2: Đặt địa chỉ tĩnh theo topology.**\n\n  Dùng bảng sau làm nguồn tham chiếu; địa chỉ interface OPNsense và host adapter phải được ghi lại sau khi user cấu hình:\n\n  | Node | WAN | SYNC | DMZ-FRONT | DMZ-APP | TRUSTED | MGMT |\n  |---|---:|---:|---:|---:|---:|---:|\n  | `opns1` | `10.0.0.1` | `192.168.50.1` | `192.168.20.1` | `192.168.21.1` | `192.168.30.1` | `192.168.99.1` |\n  | `opns2` | `10.0.0.2` | `192.168.50.2` | `192.168.20.2` | `192.168.21.2` | `192.168.30.2` | `192.168.99.2` |\n  | CARP VIP | `10.0.0.100` | n/a | `192.168.20.100` | `192.168.21.100` nếu cần | `192.168.30.100` nếu cần | `192.168.99.100` |\n  | `lb1/lb2` | n/a | n/a | `.10/.11` | n/a | n/a | stats qua MGMT nếu cần |\n  | `web1/web2` | n/a | n/a | n/a | `.21/.22` | n/a | n/a |\n  | `pg1/pg2` | n/a | n/a | n/a | n/a | `.11/.12` | n/a |\n  | `obs` | n/a | n/a | n/a | n/a | n/a | `.30` |\n  | `ca` | n/a | n/a | n/a | n/a | n/a | `.31` |\n  | `attacker` | `.20` | n/a | n/a | n/a | n/a | n/a |\n  | `sensor` | `.21` | n/a | n/a | n/a | n/a | n/a |\n\n  `192.168.50.1/.2` là địa chỉ sync riêng; không dùng `10.0.0.2` cho pfsync/cfgsync. Đây là điểm cần sửa so với đoạn tham chiếu trong HTML.\n\n- [ ] **Step 2.3: Tạo host adapter và kiểm từ Windows.**\n\n  User chạy:\n\n  ```powershell\n  Get-NetAdapter -Name 'VMware Network Adapter*'\n  Get-NetIPAddress -AddressFamily IPv4 |\n    Where-Object InterfaceAlias -like 'VMware Network Adapter*' |\n    Format-Table InterfaceAlias,IPAddress,PrefixLength\n  ```\n\n  Ping/TCP tới smoke-test VM trên từng subnet có VM. Không dùng ping làm bằng chứng cho subnet mà firewall được thiết kế để drop ICMP; dùng `Test-NetConnection -ComputerName <ip> -Port <port>` khi phù hợp.\n\n- [ ] **Step 2.4: Kiểm promiscuous capture.**\n\n  User chỉ làm trên vmnet WAN private. Gắn hai VM test cùng segment, chạy tcpdump ở sensor và tạo traffic từ attacker. Nếu không bắt được traffic của VM khác, user kiểm tra VMware security/promiscuous setting và chỉ tiếp tục sau khi ghi rõ giới hạn.\n\n- [ ] **Step 2.5: Assistant đối chiếu topology.**\n\n  Assistant kiểm tra không có node attacker trên DMZ-FRONT/DMZ-APP/TRUSTED, không có NIC thừa, không có subnet trùng và host adapter đủ để ProxyJump.\n\n**Pass P2:** Sáu mạng tồn tại, DHCP/NAT/bridged sai đều tắt, host reachability đúng, sensor capture smoke-test có bằng chứng.\n\n**Fail P2:** Không cài dịch vụ. Giữ một vmnet test duy nhất hoặc sửa VMware network editor. Không cố giải quyết L2 bằng Tailscale route advertisement.\n\n---\n\n## Task 3: Dựng VM theo profile, không bật cả 12 VM cùng lúc\n\n**Owner:** USER tạo VM/snapshot; ASSISTANT chuẩn bị inventory sau khi VM có địa chỉ.\n\n**Mục tiêu:** Giữ RAM trong giới hạn 32 GB và có rollback sạch.\n\n- [ ] **Step 3.1: Chuẩn bị template Debian 12.**\n\n  User cài Debian 12 minimal một lần, cập nhật package, tạo `ops`, SSH key-only, timezone/NTP và tắt service không cần. Chụp snapshot `clean-template`. Không đặt secret dự án vào template.\n\n- [ ] **Step 3.2: Tạo core profile trước.**\n\n  Bật theo thứ tự:\n\n  1. `opns1`, `opns2`\n  2. `lb1`, `lb2`\n  3. `web1`, `web2`\n  4. `pg1`, `pg2`\n\n  Dùng RAM tham chiếu: OPNsense 2 GB/node, LB 512 MB/node, web 1 GB/node, PostgreSQL 1.5 GB/node. Nếu host bắt đầu paging mạnh, tắt LB/web/DB không liên quan thay vì tăng WSL limit.\n\n- [ ] **Step 3.3: Tạo observe profile.**\n\n  Thêm `obs` khoảng 2.5 GB và `ca` khoảng 512 MB. Chỉ bật sau khi core profile pass. Tổng steady state mục tiêu khoảng 13.5-15 GB VM RAM tùy dịch vụ.\n\n- [ ] **Step 3.4: Tạo attack profile.**\n\n  Thêm `attacker` khoảng 2 GB và `sensor` khoảng 1.5 GB chỉ trong phiên test. Tắt sau test. Không chạy attack profile cùng browser/IDE nặng nếu host bắt đầu dùng memory compression mạnh.\n\n- [ ] **Step 3.5: Gắn NIC theo node.**\n\n  Mỗi OPNsense có 6 NIC logic: WAN, SYNC, DMZ-FRONT, DMZ-APP, TRUSTED, MGMT. Linux service VM chỉ gắn đúng vùng cần dùng; không gắn thêm WAN cho web/DB.\n\n- [ ] **Step 3.6: Chụp snapshot.**\n\n  Chụp `clean` sau khi OS/NIC/IP/NTP/SSH cơ bản pass. Chụp thêm `before-carp`, `before-policy`, `IPS-off`, `before-db-failover` trước các phase tương ứng.\n\n- [ ] **Step 3.7: Cập nhật inventory.**\n\n  Assistant tạo `inventory/hosts.yml` và `docs/interfaces.md` từ mapping user cung cấp. Không hardcode Tailscale IP hoặc secret.\n\n**Pass P3:** Core VM có đúng NIC/subnet, SSH tới Linux VM qua ProxyJump, OPNsense console/GUI truy cập được, snapshot `clean` tồn tại, `vmrun list` hiển thị đúng VM đang bật.\n\n**Fail P3:** Xóa khỏi inventory các VM chưa cần, không xóa file VM hoặc snapshot nếu chưa được user xác nhận. Tiếp tục với vertical slice `opns1 -> lb1 -> web1`.\n\n---\n\n## Task 4: Cấu hình OPNsense một node rồi mới HA\n\n**Owner:** USER trên OPNsense console/GUI; ASSISTANT kiểm tra policy/topology và chuẩn bị checklist.\n\n**Mục tiêu:** Có routing/firewall cơ bản trước, sau đó mới bật CARP/pfsync/cfgsync.\n\n- [ ] **Step 4.1: Cấu hình `opns1` interface mapping.**\n\n  Trên console OPNsense, map đúng NIC theo MAC/VMware order; đặt description `wan`, `sync`, `dmz_front`, `dmz_app`, `trusted`, `mgmt`. Không tin thứ tự `em0/em1` nếu chưa đối chiếu MAC.\n\n- [ ] **Step 4.2: Đặt IP/gateway và HTTPS GUI.**\n\n  Cấu hình IP theo bảng P2, bật HTTPS GUI trên MGMT, tạo user admin riêng, lưu config backup cục bộ. Chưa mở GUI trên WAN.\n\n- [ ] **Step 4.3: Tạo policy tối thiểu thủ công.**\n\n  Cho phép WAN DNAT TCP/443 tới LB VIP, cho phép các kết nối bootstrap cần thiết, block WAN tới TRUSTED/MGMT, block DMZ-APP/TRUSTED egress WAN. Ghi mỗi rule bằng một ID tạm tương ứng `POL-001`...`POL-005`.\n\n- [ ] **Step 4.4: Tạo dịch vụ giả trên `lb1`.**\n\n  User chạy trên LB test:\n\n  ```bash\n  sudo nc -lvnp 443\n  ```\n\n  Từ attacker hoặc máy test trên WAN, kiểm tra DNAT bằng `curl -k`/`nc` phù hợp. Không kiểm từ Internet.\n\n- [ ] **Step 4.5: Cấu hình `opns2` giống version/interface order.**\n\n  Cài đúng phiên bản OPNsense, map NIC bằng MAC, đặt IP node riêng và sync IP `192.168.50.2`. Chụp `before-carp` trước khi bật HA.\n\n- [ ] **Step 4.6: Bật CARP từng zone.**\n\n  Tạo VIP với vhid khác nhau cho WAN, DMZ-FRONT, DMZ-APP, TRUSTED và MGMT; node master `advskew 0`, backup `advskew 100`; tắt preempt để tránh flap khi node hồi.\n\n- [ ] **Step 4.7: Bật pfsync trên SYNC.**\n\n  pfsync chỉ chạy qua `192.168.50.0/24`, không qua WAN. User xác nhận bằng console:\n\n  ```text\n  ifconfig carp\n  tcpdump -i <sync-interface> -nn proto 240\n  ```\n\n  Với pfsync FreeBSD, proto 240 là giá trị cần kiểm tra; nếu phiên bản hiển thị khác, ghi output thực tế thay vì đoán.\n\n- [ ] **Step 4.8: Bật cfgsync có chủ động.**\n\n  Tạo user sync quyền tối thiểu, snapshot trước lần sync đầu, tắt auto-sync trong lúc sửa tay. Kiểm tra sửa trên backup không bị ghi đè im lặng và drift có cảnh báo.\n\n- [ ] **Step 4.9: Chạy test HA tối thiểu.**\n\n  - Giữ một SSH/iperf session qua VIP.\n  - Tắt node master bằng thao tác user đã xác nhận.\n  - Đo thời gian VIP đổi master.\n  - Cắt vmnet-sync, xác nhận không có hai MASTER.\n  - Khôi phục node và kiểm preempt không gây flap.\n\n**Pass P4:** T-04, T-05 và phần nền của T-06 có số liệu; một CARP master mỗi VIP; session dài và state sync hoạt động.\n\n**Fail P4:** Tắt cfgsync và rollback `before-carp`; giữ một OPNsense để làm vertical slice. Không bật IPS hoặc DB failover.\n\n---\n\n## Task 5: Tạo repo control plane và policy-as-code\n\n**Owner:** ASSISTANT viết artifact; USER cung cấp giá trị môi trường và chạy lệnh có quyền/network.\n\n**Mục tiêu:** Biến YAML thành nguồn chân lý, apply idempotent và có validator trước khi triển khai dịch vụ.\n\n- [ ] **Step 5.1: Assistant khởi tạo cấu trúc repo.**\n\n  Tạo các file trong phần File structure: `.gitignore`, `Makefile`, `ansible.cfg`, inventory, policy schema, `scripts/validate_policy.py`, test self-check và `docs/checkpoints.md`.\n\n- [ ] **Step 5.2: Assistant viết policy YAML tối thiểu.**\n\n  `policy/zones.yml` phải có:\n\n  ```yaml\n  zones:\n    wan: {net: 10.0.0.0/24, iface: wan}\n    dmz_front: {net: 192.168.20.0/24, iface: opt1}\n    dmz_app: {net: 192.168.21.0/24, iface: opt2}\n    trusted: {net: 192.168.30.0/24, iface: opt3}\n    mgmt: {net: 192.168.99.0/24, iface: opt4}\n\n  aliases:\n    LB_VIP: {type: host, items: [192.168.20.100]}\n    APP_NODES: {type: network, items: [192.168.21.21/32, 192.168.21.22/32]}\n    DB_VIP: {type: host, items: [192.168.30.100]}\n    MGMT_ONLY: {type: network, items: [192.168.99.0/24]}\n\n  rules:\n    - id: POL-001\n      desc: Public HTTPS vao LB VIP\n      zone: wan -> dmz_front\n      proto: tcp\n      dst: LB_VIP\n      dport: [443]\n      action: pass\n      log: true\n      test: T-07\n      reason: Public entrypoint only\n  ```\n\n  Các rule còn lại phải thêm trước khi apply production: web-to-DB, WAN-to-DB block, DMZ/TRUSTED egress block, SSH MGMT-only, observability access và NAT.\n\n- [ ] **Step 5.3: User cài dependency tối thiểu trong distro control plane.**\n\n  Assistant đưa lệnh cụ thể theo distro đã chọn. User xác nhận cài package/network. Tối thiểu cần Python, pipx hoặc venv, Ansible, `yamllint`, `pytest`, `gitleaks` và OpenSSH client. Không cài Docker/Podman nếu không có service cần container.\n\n- [ ] **Step 5.4: User bật API OPNsense và tạo credential tối thiểu.**\n\n  User tạo API user/key/secret trên OPNsense GUI, lưu bằng Ansible Vault hoặc secret manager cục bộ. Không gửi key/secret cho assistant. Chỉ gửi:\n\n  - phiên bản OPNsense;\n  - HTTP status;\n  - endpoint path;\n  - tên field JSON sau khi che giá trị;\n  - thông báo lỗi đã loại credential.\n\n- [ ] **Step 5.5: User xác nhận endpoint API trong 30 phút.**\n\n  Chạy curl cục bộ với biến môi trường, không ghi command có secret vào shell history nếu có thể:\n\n  ```bash\n  curl -k -u \"$OPNS_API_KEY:$OPNS_API_SECRET\" \\\n    'https://<opns-mgmt-ip>/api/firewall/alias/searchAlias'\n  curl -k -u \"$OPNS_API_KEY:$OPNS_API_SECRET\" \\\n    -X POST -H 'Content-Type: application/json' \\\n    -d '{\"alias\":{\"name\":\"LAB_PROBE\",\"type\":\"host\",\"content\":\"192.0.2.1\"}}' \\\n    'https://<opns-mgmt-ip>/api/firewall/alias/addItem'\n  curl -k -u \"$OPNS_API_KEY:$OPNS_API_SECRET\" \\\n    'https://<opns-mgmt-ip>/api/firewall/filter/apply'\n  ```\n\n  Endpoint cuối cùng phải lấy theo API docs/version thực tế. Nếu `LAB_PROBE` được tạo, user xóa nó bằng GUI/API sau khi kiểm chứng.\n\n- [ ] **Step 5.6: Assistant viết renderer sau khi API contract được xác nhận.**\n\n  Renderer phải:\n\n  - map rule theo `POLICY-ID`, không theo vị trí;\n  - chạy lần hai không tạo duplicate;\n  - xóa rule không còn trong YAML;\n  - validate alias trước rule;\n  - dry-run/diff trước apply;\n  - apply rồi post-check counters/state;\n  - không log credential hoặc response chứa secret.\n\n- [ ] **Step 5.7: Assistant viết validator 24 combo.**\n\n  Validator tạo danh sách nguồn/đích/port theo zone, expected action từ YAML, command plan và CSV schema. Không tự động tạo traffic phá hoại; harness chỉ chạy sau user xác nhận lab private.\n\n- [ ] **Step 5.8: User chạy policy lint và apply trên vertical slice.**\n\n  ```bash\n  make policy-lint\n  make check\n  ansible-playbook -i inventory/hosts.yml playbooks/apply_policy.yml --check\n  ansible-playbook -i inventory/hosts.yml playbooks/apply_policy.yml\n  make drift\n  ```\n\n- [ ] **Step 5.9: Chạy T-08 dưới tải nhẹ.**\n\n  User tạo 30 request/s từ attacker hoặc load generator đã giới hạn, ghi state count trước/sau, lỗi 5xx, lỗi connection và rule counter. Không chạy flood ở task này.\n\n**Pass P5:** `make check`, policy schema, dry-run, apply lần đầu/lần hai, xóa rule và drift đều đúng; T-08 không mất state.\n\n**Fallback:** Nếu API không khớp, assistant giữ YAML/schema/validator nhưng dừng renderer. User có thể chọn phương án B render `config.xml` + reboot, nhưng phải ghi rõ NFR-02 không còn là apply không gián đoạn. Không giả vờ đạt yêu cầu.\n\n---\n\n## Task 6: Dựng HAProxy, web, Keepalived và PostgreSQL nền\n\n**Owner:** ASSISTANT viết role/playbook; USER cài package, cấp secret/cert và xác nhận network/service.\n\n- [ ] **Step 6.1: Bootstrap Linux VM không phá hủy.**\n\n  Assistant viết `playbooks/bootstrap.yml` để tạo user/service directory, SSH hardening, NTP, package baseline và facts. User chạy dry-run trước.\n\n- [ ] **Step 6.2: Dựng web app tối giản.**\n\n  Assistant chuẩn bị app có `/healthz`, `/whoami`, `GET/POST /note`, `/session`; session lưu PostgreSQL, không thêm Redis. User cung cấp runtime được chọn và xác nhận package source.\n\n- [ ] **Step 6.3: Dựng web1/web2 với Apache và TLS client-auth.**\n\n  User/assistant tách rõ cert public khỏi private key. User tạo/giữ private key; assistant viết template cấu hình. Kiểm client cert hợp lệ/không hợp lệ từ LB.\n\n- [ ] **Step 6.4: Dựng HAProxy lb1/lb2.**\n\n  Cấu hình TLS termination, ALPN, health check `/healthz`, mTLS xuống web, stats chỉ trên MGMT. Assistant thêm `haproxy -c` vào `make check`.\n\n- [ ] **Step 6.5: Dựng Keepalived VIP.**\n\n  User xác nhận multicast VMware trước khi dùng. Assistant viết role với `track_script` kiểm `haproxy -c`, user chạy T-03 và đo đổi VIP <= 10 giây.\n\n- [ ] **Step 6.6: Dựng PostgreSQL 16.**\n\n  User đặt password/replication secret cục bộ. Assistant viết role cho `synchronous_commit=on`, `hostssl`, SCRAM, replication slot và `pg_stat_replication` check. Không cho app dùng IP node; app chỉ dùng DB VIP.\n\n- [ ] **Step 6.7: Dựng DB VIP và manual promote đầu tiên.**\n\n  Không bật automatic failover trước khi có fencing. Assistant chuẩn bị `promote.sh` dạng dry-run/logging; user chạy manual promote trong snapshot lab và xác nhận node cũ không còn writer.\n\n- [ ] **Step 6.8: Chạy checkpoint dịch vụ.**\n\n  - T-01: load phân phối tới web1/web2.\n  - T-02: tắt một web node, session còn.\n  - T-03: Keepalived VIP đổi chủ.\n  - PostgreSQL standby nhận WAL.\n  - Không có hai writer.\n\n**Pass P6:** T-01, T-02, T-03 pass; TLS/mTLS pass; PostgreSQL replication và fencing manual có bằng chứng.\n\n**Cắt phạm vi nếu fail:** Giữ streaming replication + manual promote + PITR; bỏ automatic failover trước, không bỏ DB VIP nếu mục tiêu vẫn yêu cầu app stateless.\n\n---\n\n## Task 7: Bật Suricata inline, WAF và observability theo từng lớp\n\n**Owner:** USER bật/tắt trên thiết bị; ASSISTANT viết config/check/parser.\n\n- [ ] **Step 7.1: Chụp snapshot `IPS-off`.**\n\n  User xác nhận có đường tắt phục hồi: console/GUI hoặc lệnh đã thử. Không bật IPS trên ba zone cùng lúc.\n\n- [ ] **Step 7.2: Chạy Suricata detection-only.**\n\n  Xác nhận traffic path, rule load và alert trước khi blocking. Assistant thêm config validation; user kiểm `suricata -T` và log.\n\n- [ ] **Step 7.3: Bật inline blocking trên WAN.**\n\n  User bật NFQUEUE/IPS trên WAN, chạy nmap/scan trong vmnet private, ghi latency và alert. Chỉ mở rộng DMZ-FRONT rồi DMZ-APP sau khi WAN ổn.\n\n- [ ] **Step 7.4: Kiểm fail-closed/fail-open thật.**\n\n  User dừng Suricata trong một cửa sổ test có snapshot, kiểm kết nối từ attacker, khôi phục service và ghi hành vi thật. Không tuyên bố fail-closed chỉ dựa trên cấu hình.\n\n- [ ] **Step 7.5: Bật mod_security2 + OWASP CRS.**\n\n  Assistant quản lý override/rule có `Reason:`; user xác nhận ParanoiaLevel 2 và chạy 15 request hợp lệ để đo false positive trước khi chạy 30 payload test.\n\n- [ ] **Step 7.6: Dựng CA/mTLS bằng step-ca.**\n\n  User giữ CA private key và root backup. Assistant viết role/cấu hình cert path/TTL 7 ngày; user cấp cert qua quy trình local. Không commit `certs/issued/` hoặc key.\n\n- [ ] **Step 7.7: Dựng obs/logging.**\n\n  Dựng rsyslog receiver, Loki, Prometheus/Grafana, node/haproxy/postgres exporter. Assistant tạo dashboard tối thiểu: policy hit, IPS block, WAF block, state table, 5xx, DB leader, backup age.\n\n- [ ] **Step 7.8: Dựng sáu alert.**\n\n  - CARP master mất/đổi.\n  - IPS down.\n  - Rule counter bất thường.\n  - 5xx > 1%.\n  - DB leader đổi.\n  - Backup > 24 giờ.\n\n  User kích hoạt ít nhất một alert thật, assistant kiểm query/evidence.\n\n- [ ] **Step 7.9: Chạy T-09, T-10 và T-12.**\n\n  Chỉ chạy từ attacker private. Payload phải là bộ kiểm thử của lab; không nhắm hệ thống ngoài. T-10 phải có log cảnh báo và hành vi đã công bố.\n\n**Pass P7:** IPS block thật, WAF không false-positive với 15 request hợp lệ, có alert thật và truy vết được một request qua LB/web/DB.\n\n**Rollback:** Tắt blocking hoặc quay `IPS-off`; hạ CRS về DetectionOnly; giữ raw log và một alert có bằng chứng trước khi tối ưu dashboard.\n\n---\n\n## Task 8: PITR, attack harness và ma trận kiểm thử\n\n**Owner:** USER chạy test phá hoại; ASSISTANT viết harness/parser/report và review evidence.\n\n- [ ] **Step 8.1: Dựng pgBackRest repository trên `obs`.**\n\n  User chọn SSH hoặc NFS repo, tạo key/quyền tối thiểu, kiểm dung lượng và backup encryption key. Assistant viết cấu hình template không chứa secret.\n\n- [ ] **Step 8.2: Chạy full/incremental/WAL archive.**\n\n  Ghi timestamp, dung lượng, WAL lag và retention. Không xóa backup cũ trong lúc chưa verify restore.\n\n- [ ] **Step 8.3: Chạy PITR trên instance mới.**\n\n  User tạo timestamp marker, thêm ba bản ghi mốc, restore instance riêng tới timestamp và verify ba bản ghi. Không restore đè production DB lần đầu.\n\n- [ ] **Step 8.4: Assistant tạo `run_matrix.sh` và schema CSV.**\n\n  Schema bắt buộc:\n\n  ```text\n  scenario,ts,host,detect_s,rto_s,req_total,err_5xx,err_conn,pass\n  ```\n\n  Script không tự giả định `pass`; mỗi test phải trả exit code và evidence path.\n\n- [ ] **Step 8.5: Chạy test theo thứ tự an toàn.**\n\n  1. T-01 phân phối tải.\n  2. T-02 chết một web.\n  3. T-03 Keepalived VIP.\n  4. T-07 policy matrix.\n  5. T-08 apply policy dưới tải nhẹ.\n  6. T-04 CARP failover giữ session.\n  7. T-05 cắt pfsync/heartbeat.\n  8. T-06 cfgsync drift.\n  9. T-09 scan/payload.\n  10. T-11 SSH brute force giới hạn trong lab.\n  11. T-12 WAF false positive.\n  12. T-13 DB failover + PITR.\n  13. T-10 IPS stop behavior.\n  14. T-14 egress block và flood test giới hạn.\n\n- [ ] **Step 8.6: Chạy T-14 flood chỉ khi có xác nhận an toàn.**\n\n  User phải xác nhận cả sáu điều: mọi NIC private, không default route ngoài thiết kế, attacker đúng VM, sensor đang thu bằng chứng, có snapshot, có lệnh abort. Nếu generator không phát được 50k pkt/s, ghi tốc độ thực tế và giới hạn laptop; không ghi “đạt” chỉ vì lệnh chạy xong.\n\n- [ ] **Step 8.7: Assistant tạo báo cáo từ CSV.**\n\n  `report.py` tổng hợp pass/fail, RTO/RPO, 5xx, connection error, timestamp, direct/DERP và evidence path; không nhúng secret hoặc payload nhạy cảm không cần thiết.\n\n**Pass P8:** 14 test có kết quả và evidence; PITR verify ba bản ghi; mọi fail có nguyên nhân và mức ảnh hưởng.\n\n---\n\n## Task 9: Rebuild drill, tài liệu và bàn giao\n\n**Owner:** TOGETHER; user thao tác VM/snapshot, assistant kiểm repo/evidence.\n\n- [ ] **Step 9.1: Chụp snapshot `green`.**\n\n  User chụp sau khi core test pass và backup đã verify. Ghi timestamp/NTP.\n\n- [ ] **Step 9.2: Rebuild một service không phá toàn lab.**\n\n  Chọn web1 hoặc lb1 trước. User xóa/cài lại service theo quy trình đã được phê duyệt; assistant chạy playbook từ WSL. Đo từ lúc bắt đầu tới khi health check pass.\n\n- [ ] **Step 9.3: Rebuild một VM từ snapshot/template.**\n\n  Chỉ làm sau khi backup template và inventory đã commit nội bộ. User thao tác VMware; assistant kiểm `ansible-playbook`, `make check`, health check và policy drift.\n\n- [ ] **Step 9.4: Viết báo cáo trade-off.**\n\n  Bắt buộc nêu:\n\n  - WSL là control plane nhẹ.\n  - OPNsense/VMware giữ L2/HA/IPS.\n  - ProxyJump là out-of-band management, không đi qua perimeter.\n  - NFR-13 chỉ phân tách logic trên một host.\n  - API OPNsense version đã xác nhận thế nào.\n  - Tốc độ flood thực tế và giới hạn phần cứng.\n  - RPO chỉ bằng 0 cho commit đã synchronous-ack, không đồng nghĩa giao dịch đang in-flight.\n  - Các test fail và lý do không che giấu.\n\n- [ ] **Step 9.5: Đóng gói handoff.**\n\n  Repo phải có README, runbook user, inventory không secret, policy, test matrix, checkpoint log, backup/restore instructions và lệnh tắt lab an toàn. Không commit snapshot/VHDX/PCAP lớn hoặc private key.\n\n**Pass P9:** Một người khác đọc README có thể biết cách bật profile, chạy `make check`, vào lab qua ProxyJump, rollback snapshot và chạy test chính.\n\n---\n\n## Lộ trình 14 ngày\n\n| Ngày | User | Assistant | Mốc cuối ngày |\n|---|---|---|---|\n| 1 | P0, Tailscale, OpenSSH, WSL profile | Review baseline, chuẩn bị interface checklist | P1 bắt đầu |\n| 2 | Smoke VM, ProxyJump, 6 vmnet | `docs/interfaces.md`, repo skeleton | ProxyJump vào được VM |\n| 3 | OPNsense1, routing, DNAT | IP/policy schema | Attacker chạm dịch vụ giả |\n| 4 | OPNsense2, CARP nền | Policy YAML + 24 combo | Một master/VIP đúng |\n| 5 | pfsync/cfgsync | API contract spike | T-04/T-05 có số liệu hoặc dừng |\n| 6 | HAProxy + TLS/mTLS | Renderer idempotent + check | P5 policy pass |\n| 7 | PostgreSQL replication | Web role/app/session | T-01/T-02 pass |\n| 8 | Suricata detection/IPS | Keepalived + validator | Checkpoint 1: T-01/02/03/04/07 |\n| 9 | DB promote/fence, WAF | step-ca, out-of-band docs | T-09/T-10/T-12 pass |\n| 10 | state limit, hardening, PITR bắt đầu | Loki/syslog | Checkpoint 2 bắt đầu |\n| 11 | PITR drill | Prometheus/Grafana, attack harness | 14 test lần đầu |\n| 12 | 8 test perimeter, rebuild | 6 test service, matrix/report | 14 kết quả |\n| 13 | perimeter report, video | policy/MITRE/report | Bản nháp hoàn chỉnh |\n| 14 | rollback/retest nếu cần | review evidence | Handoff |\n\n---\n\n## Bảng cắt phạm vi khi thiếu thời gian hoặc RAM\n\nCắt theo thứ tự này, không tự ý cắt bốn năng lực định danh bản v4:\n\n1. Bỏ state-limit/SYN flood T-14a.\n2. Gộp sensor vào attacker nếu vẫn capture được bằng chứng.\n3. Bỏ đối chiếu sensor-vs-defender, giữ log phòng thủ.\n4. Chuyển IPS fail-closed thành mô tả thiết kế có lý do, chỉ khi không còn thời gian.\n5. Hạ WAF về DetectionOnly và giảm payload.\n6. Hạ PITR về full restore nếu bắt buộc.\n\nKhông cắt:\n\n- CARP + pfsync.\n- Policy-as-code + apply/drift.\n- IPS blocking.\n- Ma trận policy 24 combo.\n\nNếu phải cắt một trong bốn mục không cắt, báo cáo nên ghi rõ đây là bản v3/vertical slice thay vì gọi là v4 hoàn chỉnh.\n\n---\n\n## Checklist đầu ra assistant có thể giao theo từng mốc\n\n### Sau P1\n\n- `docs/interfaces.md` với giá trị môi trường đã được user xác nhận.\n- `README.md` skeleton.\n- `ansible.cfg` dùng ProxyJump.\n- `scripts/verify_access.sh` không chứa secret.\n\n### Sau P5\n\n- `policy/zones.yml`.\n- `policy/schema.yml`.\n- `inventory/hosts.yml`.\n- `roles/opnsense_policy/` theo API contract thật.\n- `scripts/validate_policy.py`.\n- `tests/test_policy_schema.py`.\n- `make policy-lint`, `make check`, `make drift`.\n\n### Sau P6-P7\n\n- Roles/playbooks cho HAProxy, Keepalived, web, PostgreSQL, CA và observability.\n- Health checks và config tests.\n- Dashboard/alert queries.\n- Tài liệu rollback IPS/WAF/DB.\n\n### Sau P8-P9\n\n- `scripts/run_matrix.sh`.\n- `scripts/report.py`.\n- CSV kết quả và checkpoint log.\n- Rebuild drill record.\n- Báo cáo trade-off và handoff README.\n\n---\n\n## Điều kiện để bắt đầu triển khai thật\n\nChỉ bắt đầu viết repo/playbook sau khi user xác nhận bằng output đã che secret:\n\n1. P0: baseline RAM/disk và WSL profile được chấp nhận.\n2. P1: Tailscale + Windows OpenSSH + ProxyJump tới một Debian VM pass.\n3. P2: sáu vmnet private/host-only và mapping host adapter pass.\n4. User có thể thao tác console VMware/OPNsense khi mất SSH.\n5. Có nơi lưu secret cục bộ và có snapshot/rollback.\n\n**Phương án lười hơn:** dựng trước vertical slice `opns1 -> lb1 -> web1 -> pg1`, chạy policy path và một test attack trong một ngày; chỉ nhân bản thành HA/12 VM nếu đường L2, ProxyJump và API OPNsense đã pass.\n"
}
```

**Response:**

File created successfully at: D:\Lab\docs\superpowers\plans\2026-11-07-ha-lb-security-lab-deployment.md The file state is current in your context; no need to read it back.

[hook: PostToolUse] succeeded (exit 0)

#### Thinking

**Planning self-review with grep placeholders****Ensuring absolute Markdown links for file mentions****Not committing plan without git repository**

#### Thinking

**Finalizing plan summary with options**

Runbook đã được ghi; mình đang tự rà placeholder, nhất quán tên file/lệnh và coverage các checkpoint trước khi bàn giao. Chưa có code, VM hay cấu hình Windows nào được thay đổi.

#### Tool: Grep

**Input:**

```json
{
  "pattern": "TBD|TODO|implement later|Similar to Task|Add appropriate|write tests for the above",
  "path": "D:\\Lab\\docs\\superpowers\\plans\\2026-11-07-ha-lb-security-lab-deployment.md",
  "glob": "*.md",
  "output_mode": "content",
  "-B": 0,
  "-A": 0,
  "-C": 0,
  "context": 0,
  "-n": true,
  "-i": false,
  "-o": false,
  "type": "",
  "head_limit": 100,
  "offset": 0,
  "multiline": false
}
```

**Response:**

No matches found

#### Tool: Grep

**Input:**

```json
{
  "pattern": "T-0[1-9]|T-1[0-4]|P[0-9]",
  "path": "D:\\Lab\\docs\\superpowers\\plans\\2026-11-07-ha-lb-security-lab-deployment.md",
  "glob": "*.md",
  "output_mode": "count",
  "-B": 0,
  "-A": 0,
  "-C": 0,
  "context": 0,
  "-n": false,
  "-i": false,
  "-o": false,
  "type": "",
  "head_limit": 100,
  "offset": 0,
  "multiline": false
}
```

**Response:**

docs\superpowers\plans\2026-11-07-ha-lb-security-lab-deployment.md:55

Found 55 total occurrences across 1 file.

#### Tool: Glob

**Input:**

```json
{
  "pattern": "docs/superpowers/plans/*.md",
  "path": "D:\\Lab"
}
```

**Response:**

docs\superpowers\plans\2026-11-07-ha-lb-security-lab-deployment.md

#### Thinking

**Preparing concise plan summary with file links****Updating task statuses and invoking verification**

Rà soát pass: không còn placeholder cấm, kế hoạch có đủ 14 test, checkpoint P0–P9, rollback/cắt phạm vi và phân quyền assistant/user. Mình sẽ đánh dấu phần lập kế hoạch hoàn tất rồi bàn giao lựa chọn cách thực thi; hiện chưa bắt đầu triển khai.

#### Thinking

**Switching to sequential TaskList calls**

#### Thinking

**Finalizing plan summary and execution prompt****Incorporating absolute local file links in plan summary****Drafting precise execution choice prompt**

Kế hoạch đã hoàn tất và lưu tại [2026-11-07-ha-lb-security-lab-deployment.md](file:///D:/Lab/docs/superpowers/plans/2026-11-07-ha-lb-security-lab-deployment.md).

Kế hoạch bám theo [thiết kế lab hiện tại](file:///D:/Lab/ha-lb-security-lab.html), nhưng điều chỉnh cho môi trường thực tế:

- Chia thành P0–P9: tài nguyên, Tailscale/SSH, 6 vmnet, VM profile, OPNsense HA, policy-as-code, dịch vụ/DB, IPS/observability, test và bàn giao.
- Không tạo 12 VM ngay; bắt đầu bằng vertical slice `opns1 → lb1 → web1 → pg1`.
- WSL chỉ giữ Git, Ansible, validator và test harness; VMware giữ toàn bộ L2, OPNsense, CARP/pfsync, IPS và các VM.
- Ghi rõ việc bạn phải làm: Windows admin, VMware GUI, VM console, Tailscale, secrets, snapshot, test phá hoại.
- Ghi rõ việc tôi làm được: inventory, policy schema/YAML, Ansible roles, validator 24 combo, test matrix, parser/report và review output.
- Có checkpoint pass/fail, rollback, điều kiện dừng và bảng cắt phạm vi nếu thiếu RAM/thời gian.
- Không có code hay cấu hình hệ thống nào được thay đổi; mới chỉ tạo runbook.

Điểm bắt đầu thực tế là P0 → P1:

1. Giảm profile WSL để chừa RAM cho VMware.
2. Bật Windows OpenSSH và xác nhận Tailscale.
3. Dựng một Debian smoke-test VM.
4. Chứng minh `WSL → Tailscale → Windows SSH → ProxyJump → VM`.
5. Chỉ khi pass mới tạo 6 vmnet và nhân bản lab.

Plan complete and saved. Hai cách thực thi:

1. **Subagent-Driven** — tôi chia từng phase cho agent, review sau mỗi phase; phù hợp với kế hoạch dài.
2. **Inline Execution** — tôi triển khai trực tiếp trong session này, dừng ở mỗi checkpoint để bạn thao tác phần Windows/VMware.

Bạn chọn `1` hoặc `2`.

[hook: Stop] succeeded (exit 0)

[hook: Stop] succeeded (exit 0)
