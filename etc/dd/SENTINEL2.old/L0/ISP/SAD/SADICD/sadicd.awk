BEGIN {blank=1;rec="";}
END {record()}

/^EXIT$/ {exit}

/^$/ { blank=1; record(); next }

/^Rank/ {next}

/Structure ID *UINT *INTEGER *Z_IDENTITY$/ { next }


/^[A-Z]/ && (blank==1) {header=1}

(header==1) {
	blank=0
	p=match($0,/ [0-9][0-9]*,[0-9][0-9]* /);
	$0=substr($0,RSTART+1,1000)" "substr($0,0,RSTART-1)
} 

(header==1) {
	header=0
	st=$1; sub(",","_",st)

	prid=$2
	if(prid==11) {pridstr="AOCS"}
	else if(prid==37) {pridstr="STR1"}
	else if(prid==38) {pridstr="STR2"}
	else if(prid==9) {pridstr="MSIC"}
	else {pridstr="ERROR"}

	pcat=$3
	apid=$4
	datatn=$5
	len=$6
	var=$7
	discrim=$8
	sid=$9
	pid_inter=$10
	pid_valid=$11
	spid=$12
	gen_stat=$13
	code=$14
	descr=$0; sub("^.* "code" ","",descr)

	dd="DataTM_"st"_"pridstr"_"sid"_"pcat"_"descr
	if(ddfile!="") {close(ddfile)}

	gsub(/\([^)]*\)/,"",dd)
	gsub(/  */,"_",dd)
	gsub(/_*$/,"",dd)
	ddfile=dd".dd"

	printf("%s|%s|*\n#\n",dd,"S2 SAD SRDB="code" APID="apid": "descr" TM("$1",PRID="pridstr" SID="sid" PCAT="pcat")") > ddfile
	printf("sid|UChar|SID Code|1\n") > ddfile

	next
}

(header==0) && (($1=="_") || ($1 ~ /^[0-9]*$/)) {

	record()

	type=""
	descr=""
	if(match($0,/ UINT /)) {type="UINT"}
	if(match($0,/ SINT /)) {type="SINT"}
	else if(match($0,/ DOUI3 /)) {type="DOUI3"}
	gsub(" "type" .*$","")

	if(type=="") {type="UINT"}
	rec="___"type " " $0
	next
}

(header==0) && ($1 !~ /^[0-9]*$/) && ($1 !~ /^___/) {
	rec=rec" "$0
	next
}

function record() {

	if(rec=="") {return;}

	num_fields=split(rec,r)
	t=r[1]


	rank=r[2]
	ofst=r[3]
	len=r[4]/8

	if(t=="___UINT") {
		if(len<=1) { type="UChar"}
		else if(len<=2) {type="UShort"}
		else if(len<=4) {type="ULong"}
		else {type="ULLong"}
	} else if(t=="___SINT") {
		if(len<=1) { type="SChar"}
		else if(len<=2) {type="SShort"}
		else if(len<=4) {type="SLong"}
		else {type="SLLong"}
	} else if(t=="___DOUI3") {
		type="Double"
	} else {
		type="Unknown"
	}

	code=r[5]
	param=r[6]
	if(num_fields<7) {
		descr=""
	} else {
		descr=rec
		sub("^.* "param" ","",descr)
	}

	if(rank=="_") {
		printf("~%s|%s|%s|%% bits(%s,%d,%d)\n", param,type,descr" SRDB="code,param_word,len_word-ofst-len*8,len*8) > ddfile
	} else {
		printf("%s|%s|%s|%d|*\n", param,type,descr" SRDB="code,len) > ddfile
		param_word=param
		len_word=len*8
	}
	rec=""

}
