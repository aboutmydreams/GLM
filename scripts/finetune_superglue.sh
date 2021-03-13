DATA_ROOT=/root/data/superglue
source config_tasks/model_blocklm_roberta_large.sh $2
source $1

CHECKPOINT_PATH="/root/data/finetune_checkpoints"

MASTER_PORT=$(shuf -n 1 -i 10000-65535)
DISTRIBUTED_ARGS="--nproc_per_node 4 --nnodes 1 --node_rank 0 --master_addr localhost --master_port $MASTER_PORT"
DATESTR=$(date +"%m-%d-%H-%M")

mkdir logs
for seed in 1234 5678 8942
do
  python -m torch.distributed.launch $DISTRIBUTED_ARGS finetune_gpt2.py \
         --finetune \
         --experiment-name ${EXPERIMENT_NAME}_3token/${seed} \
         --task ${TASK_NAME} \
         --data-dir ${DATA_PATH} \
         --save ${CHECKPOINT_PATH} \
         --seq-length ${MAX_SEQ_LEN} \
         --checkpoint-activations \
         --batch-size 8 \
         --eval-batch-size 16 \
         --save-epoch 100 \
         --continuous-prompt \
         --pattern-id 3 \
         $MODEL_ARGS \
         $TRAIN_ARGS \
         $COMMON_ARGS \
         --seed ${seed} \
         --epochs ${EPOCH_SINGLE} \
         --lr ${LR_SINGLE} \
         2>&1 | tee logs/log-${EXPERIMENT_NAME}.txt
done