#!/bin/bash
# Least Privilege Test Script for app_user
# Run from DB-Primary SSH session or via ssh ops@172.20.40.11

echo "=== STEP 1: Set temporary password ==="
ssh ops@172.20.40.11 "sudo -u postgres psql -c \"ALTER USER app_user PASSWORD 'DemoPass123!';\""

echo ""
echo "=== STEP 2: INSERT test (should succeed) ==="
ssh ops@172.20.40.11 "PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c \"INSERT INTO health_checks(node_name, status) VALUES ('TEST-LEAST-PRI', 'OK') RETURNING id;\""

echo ""
echo "=== STEP 3: UPDATE test (should succeed) ==="
ssh ops@172.20.40.11 "PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c \"UPDATE health_checks SET status = 'OK' WHERE node_name = 'TEST-LEAST-PRI';\""

echo ""
echo "=== STEP 4: DELETE test (SHOULD FAIL - permission denied) ==="
ssh ops@172.20.40.11 "(PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c \"DELETE FROM health_checks WHERE node_name = 'TEST-LEAST-PRI';\" 2>&1 | grep -q 'permission denied' && echo '✓ PASS: DELETE BLOCKED CORRECTLY' || echo '✗ FAIL: DELETE NOT BLOCKED')"

echo ""
echo "=== STEP 5: DROP TABLE test (SHOULD FAIL - must be owner) ==="
ssh ops@172.20.40.11 "(PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c \"DROP TABLE health_checks;\" 2>&1 | grep -q 'must be owner' && echo '✓ PASS: DROP BLOCKED CORRECTLY' || echo '✗ FAIL: DROP NOT BLOCKED')"

echo ""
echo "=== STEP 6: TRUNCATE test (SHOULD FAIL) ==="
ssh ops@172.20.40.11 "(PGPASSWORD='DemoPass123!' psql -U app_user -d ha_lab_db -c \"TRUNCATE TABLE health_checks;\" 2>&1 | grep -q 'permission denied' && echo '✓ PASS: TRUNCATE BLOCKED CORRECTLY' || echo '✗ FAIL: TRUNCATE NOT BLOCKED')"

echo ""
echo "=== STEP 7: Cleanup demo data ==="
ssh ops@172.20.40.11 "sudo -u postgres psql -c \"DELETE FROM health_checks WHERE node_name = 'TEST-LEAST-PRI';\""

echo ""
echo "=== STEP 8: Final verification ==="
ssh ops@172.20.40.11 "sudo -u postgres psql -d ha_lab_db -c \"SELECT * FROM health_checks ORDER BY id DESC LIMIT 5;\""

echo ""
echo "✓ ALL TESTS COMPLETED"
