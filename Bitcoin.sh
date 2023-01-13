#!/bin/bash

# Minerador de Bitcoin
echo "Iniciando minerador de Bitcoin"

# Inicializar variáveis com valores padrão
miner_wallet=""
miner_pool=""
nthreads=1
nbatches=1
crypto=""
hashrate=""
duration=""
priority=""
max_errors=""
report_frequency=""
notify_email=""
mining_mode=""
continue_on_sleep=""
output_dir=""

# Processar opções de linha de comando
while getopts "w:p:t:b:c:r:d:o:e:n:m:s:l:" opt; do
  case $opt in
    w) miner_wallet="$OPTARG"
    ;;
    p) miner_pool="$OPTARG"
    ;;
    t) nthreads="$OPTARG"
    ;;
    b) nbatches="$OPTARG"
    ;;
    c) crypto="$OPTARG"
    ;;
    r) hashrate="$OPTARG"
    ;;
    d) duration="$OPTARG"
    ;;
    o) priority="$OPTARG"
    ;;
    e) max_errors="$OPTARG"
    ;;
    n) report_frequency="$OPTARG"
    ;;
    m) notify_email="$OPTARG"
    ;;
    s) mining_mode="$OPTARG"
    ;;
    l) continue_on_sleep="$OPTARG"
    ;;
    \?) echo "Opção inválida: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Verificar se as opções obrigatórias foram fornecidas
if [[ -z "$miner_wallet" ]] || [[ -z "$miner_pool" ]] || [[ -z "$crypto" ]]; then
  echo "Erro: carteira, pool de mineração e criptomoeda são obrigatórios"
  exit 1
fi

# Verificar se o software de mineração necessário está instalado
if ! [ -x "$(command -v minerd)" ]; then
  echo 'Error: minerd não está instalado.' >&2
  exit 1
fi

# Definir a prioridade do processo de mineração
if [[ ! -z "$priority" ]]; then
  renice $priority -p $$
fi

# Defina o diretório de saída para salvar o log de saída
if [[ -z "$output_dir" ]]; then
    output_dir="./"
fi

# Configurar a mineração
if [[ ! -z "$hashrate" ]]; then
  miner+=" --hashrate $hashrate"
fi

if [[ ! -z "$mining_mode" ]]; then
  if [[ $mining_mode == "solo" ]]; then
    miner+=" --solo"
  elif [[ $mining_mode == "pool" ]]; then
    miner+=" --pool"
  else
    echo "Error: modo de mineração inválido. Escolha entre 'solo' ou 'pool'."
    exit 1
  fi
fi

# Iniciar o processo de mineração
$miner >> miner.log 2>&1 &

# salvar o log de saída
cat miner.log >> "$output_dir/miner.log"

# Esperar o fim da mineração
if [[ ! -z "$duration" ]]; then
  sleep $duration
  echo "Mineração concluída com sucesso."
  if [[ ! -z "$notify_email" ]]; then
    echo "Enviando notificação para $notify_email"
    echo "Mineração concluída com sucesso. $(cat miner.log | grep -o "[0-9]\+ accepted" | awk '{sum+=$1} END {print sum}') moedas mineradas." | mail -s "Mineração concluída" $notify_email
  fi
else
  while true; do
    if [[ ! -z "$max_errors" ]] && [[ $(cat miner.log | grep -c "Error") -ge $max_errors ]]; then
      echo "Error: Número máximo de erros permitidos atingido. Encerrando mineração."
      exit 1
    fi
    if [[ ! -z "$report_frequency" ]] && [[ $(expr $(date +%s) - $start_time) % $report_frequency -eq 0 ]]; then
      echo "Progresso: $(cat miner.log | grep -o "[0-9]\+ accepted" | awk '{sum+=$1} END {print sum}') moedas mineradas."
    fi
    if [[ ! -z "$continue_on_sleep" ]] && [[ $continue_on_sleep -eq 0 ]] && [[ $(systemctl is-system-running) == "suspend" || $(systemctl is-system-running) == "hibernate" ]]; then
      echo "Mineração interrompida devido à suspensão do sistema"
      exit 1
    fi
  done
fi

