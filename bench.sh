
COUNT=20 ;

echo "Going to do ${COUNT} run" ;

T="$(date +%s%N)" ;

for (( c=1; c<=$COUNT; c++ ))
do
    echo -ne "+"
#    ./glilis_ex.native -n 9 bank_lsystem --png /tmp/bla.png &> /dev/null ;
#    ./glilis_ex.native -n 9 bank_lsystem --svg /tmp/bla.svg &> /dev/null ;
    ./glilis_ex.native -n 11 bank_lsystem Von_koch_bench > /dev/null ;
done ;

# in nano seconds
T="$(($(date +%s%N)-T))" ;

#the average
S="$(calc ${T}/${COUNT})" ;

# Seconds
S="$(calc ${S}/1000000000)" ;

echo ""
echo "Time: ${S}s by run, on ${COUNT} runs"
