DATA_ROOT=/dataset/c07bd62b/superglue
source config_tasks/model_blocklm_large.sh
source $1

CHECKPOINT_PATH="/dataset/fd5061f6/finetune_checkpoints"

if [ -z $N_GPU ];then
  N_GPU=2
fi
MASTER_PORT=$(shuf -n 1 -i 10000-65535)
DISTRIBUTED_ARGS="--nproc_per_node ${N_GPU} --nnodes 1 --node_rank 0 --master_addr localhost --master_port $MASTER_PORT"

PER_GPU_BS=$(($BATCH_SIZE/$N_GPU))
DATESTR=$(date +"%m-%d-%H-%M")
EXPERIMENT_NAME=${EXPERIMENT_NAME}-${DATESTR}

mkdir logs
python -m torch.distributed.launch $DISTRIBUTED_ARGS finetune_gpt2.py \
       --finetune \
       --experiment-name ${EXPERIMENT_NAME} \
       --task ${TASK_NAME} \
       --data-dir ${DATA_PATH} \
       --save ${CHECKPOINT_PATH} \
       --seq-length ${MAX_SEQ_LEN} \
       --checkpoint-activations \
       --eval-batch-size 16 \
       --save-epoch 100000 \
       $MODEL_ARGS \
       $TRAIN_ARGS \
       $COMMON_ARGS \
       --fp16 \
       --continuous-prompt \
       --pattern-id $2 \
       --num-prompt-tokens 3 \
       --batch-size ${PER_GPU_BS} \
       --epochs ${EPOCH_SINGLE} \
       --lr ${LR_SINGLE} \
       --overwrite \
       2>&1 | tee logs/log-${EXPERIMENT_NAME}.txt
