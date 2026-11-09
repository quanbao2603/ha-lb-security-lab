# Kế hoạch sửa lỗi GitHub không nhận diện contributor

## Vấn đề

Các commit của anh Hùng đã xuất hiện trong lịch sử repository, nhưng mục **Contributors** chưa hiển thị tài khoản hoặc avatar GitHub của anh Hùng.

Nguyên nhân thường gặp là email được ghi trong commit chưa được liên kết và xác minh với tài khoản GitHub tương ứng.

## Bước 1: Kiểm tra email trong commit

Chạy các lệnh sau trong repository:

```bash
git show -s --format='%h%nAuthor: %an <%ae>%nCommitter: %cn <%ce>' cb97ef4
git show -s --format='%h%nAuthor: %an <%ae>%nCommitter: %cn <%ce>' 221b816
git show -s --format='%h%nAuthor: %an <%ae>%nCommitter: %cn <%ce>' c5d629b
```

Hoặc kiểm tra toàn bộ commit của anh Hùng:

```bash
git log --all --author="Minh Hùng" --format='%h | %an <%ae> | %cn <%ce> | %s'
```

Ghi lại chính xác email trong phần **Author** và **Committer**. GitHub thường dùng email của **Author** để liên kết commit.

## Bước 2: Kiểm tra email trên GitHub

Đăng nhập đúng tài khoản GitHub của anh Hùng và mở:

```text
https://github.com/settings/emails
```

Xử lý theo từng trường hợp:

- Nếu email đã có và đã xác minh: không cần sửa commit; chờ GitHub cập nhật.
- Nếu email đã có nhưng chưa xác minh: thực hiện xác minh email.
- Nếu email chưa có: thêm chính xác email lấy được từ lệnh `git show`, sau đó xác nhận qua hộp thư.

Nếu dùng email `@users.noreply.github.com`, cần bảo đảm địa chỉ đó đúng với tài khoản GitHub của anh Hùng.

## Bước 3: Cấu hình Git cho các commit sau

Sau khi xác định email đã được GitHub xác minh:

```bash
git config user.name "Minh Hùng"
git config user.email "EMAIL_DA_DUOC_VERIFY"
```

Kiểm tra lại:

```bash
git config user.name
git config user.email
```

Nếu muốn áp dụng cho tất cả repository trên máy:

```bash
git config --global user.name "Minh Hùng"
git config --global user.email "EMAIL_DA_DUOC_VERIFY"
```

Có thể dùng email GitHub dạng sau nếu không muốn dùng email cá nhân:

```text
ID_GITHUB+USERNAME@users.noreply.github.com
```

## Bước 4: Kiểm tra một commit mới

Không cần tạo commit rỗng. Nếu có thay đổi tài liệu hoặc cấu hình hợp lý cần commit, kiểm tra thông tin trước khi push:

```bash
git log -1 --format='%h%nAuthor: %an <%ae>%nCommitter: %cn <%ce>%n%s'
```

Nếu thông tin đúng, commit thay đổi cần thiết:

```bash
git add <file-can-thay-doi>
git commit -m "docs(minh-hung): update Site B verification notes"
```

Kiểm tra lại commit mới:

```bash
git show -s --format='%h%nAuthor: %an <%ae>%nCommitter: %cn <%ce>%n%s' HEAD
```

Chỉ push sau khi đã kiểm tra đúng email:

```bash
git push origin main
```

Nếu đang làm trên branch riêng:

```bash
git push -u origin <ten-branch>
```

## Bước 5: Kiểm tra trên GitHub

Sau khi push:

1. Mở trang commit mới và kiểm tra avatar hoặc tài khoản GitHub.
2. Mở repository và kiểm tra khu vực **Contributors**.
3. Có thể mở **Insights → Contributors**.
4. Tải lại trang bằng `Ctrl + F5`.

GitHub có thể cập nhật mục Contributors chậm hơn lịch sử commit, vì vậy nếu chưa hiện ngay thì chờ thêm rồi kiểm tra lại.

## Bước 6: Không rewrite lịch sử nếu chưa cần

Không dùng các lệnh sau trong bước đầu tiên:

- `git filter-branch`
- `git filter-repo`
- `git rebase` để sửa commit đã push
- `git push --force`

Các thao tác này có thể làm thay đổi commit hash và gây lệch lịch sử của các thành viên khác. Thông thường chỉ cần thêm và xác minh đúng email GitHub là đủ để GitHub liên kết các commit.

## Nếu vẫn chưa hiện

Kiểm tra thêm:

- Đã đăng nhập đúng tài khoản GitHub chưa.
- Email trong commit có giống chính xác email đã thêm vào GitHub không.
- Email đã được xác minh chưa.
- Commit đã nằm trên branch mặc định `main` chưa.
- Repository có phải repository chính, không phải bản fork không.
- Email commit có bị sai ký tự hoặc dùng nhầm địa chỉ không.

Kiểm tra commit có nằm trên `main`:

```bash
git branch --contains cb97ef4
git branch --contains 221b816
git branch --contains c5d629b
```

Nếu kết quả có `main`, commit đã nằm trên branch chính.

## Kết quả mong muốn

Sau khi hoàn tất:

- Commit cũ của anh Hùng vẫn giữ nguyên.
- Commit mới sử dụng email đã liên kết với GitHub.
- Trang commit hiển thị avatar hoặc tài khoản GitHub của anh Hùng.
- Mục Contributors nhận diện thêm tài khoản của anh Hùng.
- Không cần force push hoặc viết lại lịch sử repository.
