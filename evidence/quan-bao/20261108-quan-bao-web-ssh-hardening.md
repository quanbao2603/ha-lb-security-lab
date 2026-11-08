# Evidence — Hardening SSH web node (key-only)

- Ngày: 2026-11-08 (Asia/Ho_Chi_Minh, +07)
- Người thực hiện: Quan Bảo
- Máy áp dụng: Web-A (192.168.179.171), Web-B (192.168.179.172)
- Máy kiểm tra client: Windows host (CMD, OpenSSH)
- Phạm vi: Site A — web hardening

## Mục tiêu

Chỉ cho SSH bằng key; cấm root SSH và cấm password/keyboard-interactive.

## Cấu hình áp dụng (trên mỗi web node)

`/etc/ssh/sshd_config.d/99-hardening.conf`:

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
```

Lệnh:

```bash
printf 'PermitRootLogin no\nPasswordAuthentication no\nKbdInteractiveAuthentication no\n' | sudo tee /etc/ssh/sshd_config.d/99-hardening.conf
sudo sshd -t && sudo systemctl restart ssh
sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|kbdinteractiveauthentication'
```

## Expected / Actual — cấu hình hiệu lực (sshd -T)

| Máy | Expected | Actual | Kết quả |
|---|---|---|---|
| Web-A | permitrootlogin no / passwordauthentication no / kbdinteractiveauthentication no | đúng cả 3 | PASS |
| Web-B | permitrootlogin no / passwordauthentication no / kbdinteractiveauthentication no | đúng cả 3 | PASS |

Output (cả hai máy giống nhau):

```text
permitrootlogin no
passwordauthentication no
kbdinteractiveauthentication no
```

## Expected / Actual — kiểm tra từ client Windows (Web-A)

Key-only (phải thành công):

```cmd
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no quanbao2603@192.168.179.171
```

Actual: đăng nhập thành công, không hỏi mật khẩu → PASS.

Password (phải bị chặn):

```cmd
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no quanbao2603@192.168.179.171
```

Actual:

```text
quanbao2603@192.168.179.171: Permission denied (publickey).
```

→ PASS.

Ghi chú: Web-B xác nhận cấu hình hiệu lực giống Web-A qua `sshd -T` trên máy;
kiểm tra client-side minh họa trên Web-A (cùng cấu hình drop-in). Quy trình nạp key
được thực hiện trước khi tắt password để tránh tự khóa truy cập.