for (($address_mode = 0); $address_mode -lt 5; $address_mode++)
{
    $seed = Get-Random -Minimum 1 -Maximum 1000
    $transactions = Get-Random -Minimum 1 -Maximum 10
    echo "Running test $address_mode having $transactions transactions with seed $seed"
    ./run_test.bat $address_mode $transactions $seed "c" > output-$address_mode.txt
}