#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

executable="./softmax_openmp"
data_file="softmax_threads.dat"
plot_file="softmax_threads.png"

if [[ ! -x "$executable" ]]; then
  make softmax_openmp
fi

: > "$data_file"
printf '# threads time_seconds\n' >> "$data_file"

for threads in {1..8}; do
  output="$($executable "$threads")"
  printf '%s\n' "$output"
  time_seconds="$(awk '/^Tiempo:/ {print $2}' <<< "$output")"
  if [[ -z "$time_seconds" ]]; then
    printf 'No se pudo obtener el tiempo para %d threads.\n' "$threads" >&2
    exit 1
  fi
  printf '%d %s\n' "$threads" "$time_seconds" >> "$data_file"
done

gnuplot <<GNUPLOT
set terminal pngcairo size 1000,650
set output "$plot_file"
set title "Softmax OpenMP: tiempo por numero de threads"
set xlabel "Threads"
set ylabel "Tiempo (segundos)"
set xtics 1
set grid
plot "$data_file" using 1:2 with linespoints lw 2 pt 7 title "Tiempo"
GNUPLOT

printf 'Datos: %s\n' "$data_file"
printf 'Grafica: %s\n' "$plot_file"
