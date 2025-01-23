#!/bin/sh

# 定义日志文件名
LOG_FILE="interview_data_set"

# 使用 awk 处理日志文件并生成 JSON 输出
grep error -i "$LOG_FILE"|awk '
BEGIN {
    RS = "\n"
    FS = " "
}
{
    # 提取各个字段
    month = $1
    day = $2
    time = $3
    deviceName = $4
    split($5, processIda, "[")
    split(processIda[2], processIdb, "]")
    processId = processIdb[1]
    split($0, descriptiona, "): ");
    description = descriptiona[2]
    gsub(/[0-9]/, "", $6);
    gsub(/\[\]/, "", $6);
    gsub(/\):$/, "", $6);
    gsub(/\.$/, "", $6);
    gsub(/^\(/, "", $6);
    processName =  $6;

    # 分离时间字段
    split(time, t, ":")
    hour = sprintf("%02d", t[1])
    minute = t[2]
    second = t[3]

    # 计算时间窗口
    nextHour = (hour + 1) % 24
    timeWindow = sprintf("%s00-%02d00", hour, nextHour)

    # 构建唯一键
    key = deviceName "-" processId "-" processName "-" description "-"  timeWindow

    # 统计每个键的出现次数
    count[key]++
}
END {
    printf "["
    first = 1
    for (k in count) {
        split(k, parts, "-")
        deviceName = parts[1]
        processId = parts[2]
        processName = parts[3]
        description = parts[4]
        timeWindow = parts[5]
        numberOfOccurrence = count[k]
        if (!first) {
            printf ","
        }
        printf "{\"deviceName\":\"%s\",\"processId\":\"%s\",\"processName\":\"%s\",\"description\":\"%s\",\"timeWindow\":\"%s\",\"numberOfOccurrence\":%d}",
               deviceName, processId, processName, description, timeWindow, numberOfOccurrence
        first = 0
    }
    printf "]\n"
}
' 
