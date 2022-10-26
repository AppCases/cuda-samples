#!/bin/bash

# interations for each profiling
iteration=10
# (seconds) interval between each profiling
interval=5

############################## execution ##############################
run_simpleMultiCopy="./simpleMultiCopy"
echo "execution"
for ((i = 0; i < $iteration; i++))
do
echo "$((i+1)) round"
sleep $interval
time ($run_simpleMultiCopy &> /dev/null)
echo ""
done
echo ""

############################## liveness ##############################
redshow_mode=memory_liveness
control_knobs="-ck HPCRUN_SANITIZER_LIVENESS_ONGPU=1"
# warm-up
gvprof -v -e $redshow_mode $control_knobs $run_simpleMultiCopy &> /dev/null

echo "$redshow_mode"
for ((i = 0; i < $iteration; i++))
do
echo "$((i+1)) round"
sleep $interval
time (hpcrun -e gpu=nvidia,$redshow_mode $control_knobs $run_simpleMultiCopy &> /dev/null)
echo ""
done
echo ""

############################## heatmap ##############################
redshow_mode=memory_heatmap
control_knobs="-ck HPCRUN_SANITIZER_KERNEL_SAMPLING_FREQUENCY=100 -ck HPCRUN_SANITIZER_WHITELIST=whitelist"
echo "$redshow_mode"
for ((i = 0; i < $iteration; i++))
do
echo "$((i+1)) round"
sleep $interval
time (hpcrun -e gpu=nvidia,$redshow_mode $control_knobs $run_simpleMultiCopy &> /dev/null)
echo ""
done
echo ""


