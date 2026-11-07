# Chay trong WSL2 tren may Bao (hoac truc tiep tren may Hung).
# Dung "make -n <target>" de xem lenh truoc khi chay that.
SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

AP      := ansible-playbook
INV     := inventory/lab.ini
SITE    := ansible/site.yml
RAW     := evidence/raw
SCHEMA  := policy/schema/policy.schema.json

.PHONY: help install check policy-lint syntax lint gitleaks ping facts apply drift \
        converge chaos matrix report labup labdown snapshot preflight clean

help:            ## Liet ke cac lenh
	grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

## ===== KIEM TRA (cua CI, chay truoc khi mo PR) =====
check: policy-lint syntax lint gitleaks   ## Tong kiem tra, mac dinh khi mo PR

policy-lint:     ## Validate policy/*.yml theo schema + quy uoc POL-xxx
	python3 policy/tests/test_policy_lint.py --schema $(SCHEMA) policy/

syntax:          ## Ansible syntax check toan bo playbook
	$(AP) --syntax-check $(SITE)
	for pb in ansible/pb/*.yml; do $(AP) --syntax-check $$pb; done

lint:            ## ansible-lint cho role
	ansible-lint ansible/roles --offline || ansible-lint ansible/roles

gitleaks:        ## Quet secret loi tay (bat buoc xanh truoc commit dau tien)
	gitleaks detect --source . --redact

## ===== THUC THI =====
install:         ## Cai collection theo requirements.yml
	ansible-galaxy collection install -r requirements.yml

ping:            ## Kiem tra vung nao da qua duoc ProxyJump
	ansible -i $(INV) all -m ping

preflight:       ## Cong ngay 1: ProxyJump tung vung + tailscale direct
	bash scripts/verify_access.sh

converge:        ## Dy toan bo lab theo thu tu playbook
	$(AP) $(SITE)

apply:           ## AP dung chinh sach firewall (BAO viet YAML, HUNG chay lenh nay)
	$(AP) ansible/pb/policy.yml

drift:           ## So trang thai thiet bi voi Git, khong ghi de
	$(AP) ansible/pb/policy.yml --check --diff

chaos:           ## Gay su co: make chaos S=kill_db  (xem scripts/chaos/)
	test -n "$(S)" || { echo "Tham so S bat buoc. Vi du: make chaos S=cut_carp"; exit 1; }
	bash scripts/chaos/$(S).sh

matrix:          ## Chay 14 kich ban, sinh CSV vao evidence/raw
	bash scripts/evidence/run_matrix.sh --out $(RAW)

report:          ## Dung bang so lieu + muc luc bang chung
	python3 scripts/evidence/report.py --in $(RAW) --out docs/evidence-index.md

## ===== VON MAY (goi vmrun tren may Hung qua SSH) =====
labup:           ## Bat 12 VM
	powershell.exe -File infra/vmware/vm.ps1 start --all

labdown:         ## Tat 12 VM (lenh chung, bao truoc khi goi)
	powershell.exe -File infra/vmware/vm.ps1 stop --all

snapshot:        ## make snapshot NAME=green
	test -n "$(NAME)" || { echo "Tham so NAME bat buoc"; exit 1; }
	powershell.exe -File infra/vmware/vm.ps1 snapshot --name $(NAME)

clean:           ## Xoa san phum Ansible
	find . -name '*.retry' -delete
	rm -rf evidence/derived/*
