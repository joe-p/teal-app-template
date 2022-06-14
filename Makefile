# Path to sandbox script
SANDBOX=~/git/algorand/sandbox/sandbox

# TEAL source files
APPROVAL=./approval.teal
CLEAR=./clear.teal

# App Schema
GLOBAL_BYTES=0
GLOBAL_INTS=0
LOCAL_BYTES=0
LOCAL_INTS=0

# These shouldn't need to be manually changed
ACCOUNT=`cat .account`
APP_ID=`cat .app`

# See https://developer.algorand.org/docs/clis/goal/app/create/
APP_CREATE=${SANDBOX} goal app create \
--creator ${ACCOUNT} \
--global-byteslices ${GLOBAL_BYTES} \
--global-ints ${GLOBAL_INTS} \
--local-byteslices ${LOCAL_BYTES} \
--local-ints ${LOCAL_INTS} \
--approval-prog ${APPROVAL} \
--clear-prog ${CLEAR}

account:
	# Use first account listed for testing
	${SANDBOX} goal account list | grep -oE '\b\w{58,58}\b' | head -n 1 > .account

create:
	${SANDBOX} copyTo ${APPROVAL}
	${SANDBOX} copyTo ${CLEAR}
	eval "${APP_CREATE} | grep -oE '\d+' | tail -n 1 > .app"

call:
	${SANDBOX} goal app call --app-id ${APP_ID} --from $(ACCOUNT) --sign --out ./call.txn
	${SANDBOX}  goal clerk rawsend --filename="call.txn"

info:
	# App Info
	${SANDBOX} goal app info --app-id ${APP_ID}
	# Global State
	${SANDBOX} goal app read --app-id ${APP_ID} --global

debug-create:
	${SANDBOX} copyTo ${APPROVAL}
	eval "#{APP_CREATE} --dryrun-dump --out ./create_dr.msgp"
	${SANDBOX} tealdbg debug ${APPROVAL} -d create_dr.msgp --listen 0.0.0.0

debug-call:
	${SANDBOX} goal app call --app-id ${APP_ID} --from $(ACCOUNT) --dryrun-dump --out ./call_dr.msgp
	${SANDBOX} tealdbg debug ${APPROVAL} -d call_dr.msgp --listen 0.0.0.0
