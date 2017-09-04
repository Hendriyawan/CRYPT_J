#! /system/bin/sh
# script untuk enkripsi dekripsi file jpg
# script for encryption / decryption file jpg
# (c) 2017 gdev
# kunjungi blog saya : https://gdevnet.blogspot.com
# visit my blog : https://gdevnet.blogspot.com
# jika ingin recode atau mau edit cantumkan credits
# facebook : www.fb.com/hendri.glanex (Hendriyawan)
# (!!!) Do Not Remove Author Name (!!!)

storage=`for i in /sdcard /storage/emulated/0 /storage/emulated/legacy /storage/sdcard0 /storage/sdcard1 /ext_sdcard /mnt/sdcard /mnt/media_rw/sdcard0; do [ -d $i ] && echo $i && break; done`

R='\e[1;31m'
G='\e[1;32m'
B='\e[1;34m'
Y='\e[1;33m'
C='\e[1;36m'
D='\e[0m'
function proc() {
    mesg="$*"
    echo -e "${B}[*]${D} $mesg"
}
function error() {
    mesg="$*"
    echo -e "${R}[-]${D} $mesg"
}
function result() {
    mesg="$*"
    echo -e "${G}[+]${D} $mesg"
}
# do encrypt
function do_encrypt() {
    path_target=$1
    path_encrypted=$storage/hacked
    extention=*.jpg
    if [ ! -d $path_target ]; then
        error "error : $path_target"
        error "no such file or directory !\n"
        exit 1
    fi
    cd $path_target
    if [ -f $(for i in $extention; do [ -f ] && echo $i && break; done) ]; then
        #get total of files
        total_file=$(ls $extention | grep -v ^d | wc -l)
        result "File found !"
        result "Total : $total_file"; sleep 2
        proc "Preparing..."; sleep 2
        proc "Making folder $path_encrypted"; sleep 2
        busybox mkdir -p $path_encrypted
        if [ $? -eq 0 ]; then
            result "folder success created on:$path_encrypted !"; sleep 2
            proc "encrypting is running..."; sleep 1
            for file in $path_target/$extention; do
                filename=$(basename $file)
                file_encrypted="${filename%.*}.enc64"
                proc "encrypting $file"
                base64 < $file >> $path_encrypted/$file_encrypted
            done
            if [ $? -eq 0 ]; then
                result "encrypting done !"; sleep 2
                proc "removing real file..."
                for file in $path_target/$extention; do
                    busybox rm $file
                done
                if [ $? -eq 0 ]; then
                    result "remove done !\n"
                else
                    error "remove failed !\n"
                    exit 1
                fi
            else
                error "encrypting failed !\n"
                exit 1
            fi
        fi
    else
        error "target file not found !\n"
        exit 1
    fi
}
function do_decrypt() {
    repair_path_target=$1
    path_encrypted=$storage/hacked
    extention=*.enc64
    
    cd $path_encrypted
    if [ -f $(for i in $extention; do [ -f ] && echo $i && break; done) ]; then
        total_file=$(ls $extention | grep -v ^d | wc -l)
        result "file encrypted found !"
        result "total : $total_file"
        proc "checking path to repair"; sleep 2
        if [ -d $repair_path_target ]; then
            result "Ok !"
            for file in $path_encrypted/$extention; do
                filename=$(basename $file)
                file_jpg="${filename%.*}.jpg"
                proc "decrypting $file"
                base64 -d < $file >> $repair_path_target/$file_jpg
            done
            if [ $? -eq 0 ]; then
                result "decrypting done !"; sleep 2
                proc "removing file encrypted..."
                for file in $path_encrypted/$extention; do
                    busybox rm $file
                done
                if [ $? -eq 0 ]; then
                    result "remove done !\n"
                else
                    error "remove failed !\n"
                    exit 1
                fi
            else
                error "decrypting failed !\n"
                exit 1
            fi
        else
            error "error : $repair_path_target"
            error "no such directory to repair !\n"
            exit 1
        fi
    else
        error "file encrypted not found !\n"
        exit 1
    fi  
}
option=$1
path_target=$2
case $option in
    "-e") do_encrypt $path_target;;
    "-d") do_decrypt $path_target;;
    *) error "unknow options !\n";exit 1;;
esac