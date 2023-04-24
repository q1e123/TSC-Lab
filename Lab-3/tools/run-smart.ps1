Write-Host ("Starting test execution...") -ForegroundColor Cyan

for (($address_mode = 0); $address_mode -lt 5; $address_mode++)
{
    $seed = Get-Random -Minimum 1 -Maximum 1000
    $transactions = Get-Random -Minimum 1 -Maximum 10
    Write-Host ("Running test $address_mode having $transactions transactions with seed $seed") -ForegroundColor Yellow
    ./run_test.bat $address_mode $transactions $seed "c" > output-$address_mode.txt
}

Write-Host ("-" * 100) -ForegroundColor Gray
Write-Host  "Passed tests: " (gc test.csv | select-string -pattern "PASS").length -ForegroundColor Green
Write-Host  "Failed tests: " (gc test.csv | select-string -pattern "FAIL").length -ForegroundColor Red
Write-Host "You can see the results of each individual test in the output files or you can see a summary of the tester module in the test.csv file" -ForegroundColor Yellow