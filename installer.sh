#!/bin/bash

##H Usage: installer.sh [install_dir|help]
##H
##H For more details please refer to operations page:
##H   https://wiki.classe.cornell.edu/CHESS/Private/CHESSMetadataService
#
ME=$(basename $(dirname $0))
ROOT=$(cd $(dirname $0) && pwd)
if [ "$#" -eq 1 ]; then
    echo "new root"
    ROOT=$1
fi
LOG_DIR=$ROOT/logs
FOXDEN_DIR=$ROOT
HOST=`hostname -s`
mkdir -p $LOG_DIR
mkdir -p $FOXDEN_DIR/configs
mkdir -p $FOXDEN_DIR/databases

echo "FOXDEN root     : $FOXDEN_DIR"
echo "FOXDEN configs  : $FOXDEN_DIR/configs"
echo "FOXDEN databases: $FOXDEN_DIR/databases"
echo "LOG_DIR         : $LOG_DIR"

services="Authz MetaData DataDiscovery DataBookkeeping Frontend"

# checks performs checks over used directories and env variables
checks()
{
    if ! command -v curl &> /dev/null
    then
        echo "curl could not be found, please install `curl` command and setup PATH to find it"
        exit 1
    fi
}

# helper function to download services
download_services()
{
    echo
    echo "### Download services..."
    mkdir -p releases
    if [ -f RELEASES.md ]; then
        rm -f RELEASES.md
    fi
    touch RELEASES.md
    # loop over services and download latest tar balls
    for srv in $services
    do
        echo "Checking $srv service..."
        repo="CHESSComputing/$srv"
        tag=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep "tag_name" | cut -d '"' -f 4)
        dsrv=$(echo "$srv" | tr '[:upper:]' '[:lower:]')
        url="https://github.com/$repo/releases/download/$tag/$dsrv.tar.gz"
        if [ -z "$tag" ]; then
            echo "Unable to determine latest tag for service $srv, skip it..."
            continue
        fi
        printf "%-25s\t%s\n" $srv $tag >> RELEASES.md
        if [ -f releases/$srv/$tag/srv ]; then
            echo "    Service executable releases/$srv/$tag/srv already exists..."
        else
            echo "    Download: $url"
            curl -s -L -o $srv.tar.gz $url
            mkdir -p releases/$srv/$tag
            tar -xf $srv.tar.gz -C releases/$srv/$tag
            cd releases/$srv/$tag
            make_symlink
            cd -
        fi
    done
}

# helper function to create appropriate symlink based on host architecture
make_symlink()
{
    # Detect platform and architecture
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    # Determine the appropriate executable based on the system architecture
    case "$OS-$ARCH" in
        Linux-x86_64)
            TARGET="srv_amd64"
            ;;
        Linux-arm64 | Linux-aarch64)
            TARGET="srv_arm64"
            ;;
        Darwin-x86_64)
            TARGET="srv_darwin_amd64"
            ;;
        Darwin-arm64)
            TARGET="srv_darwin_arm64"
            ;;
        Linux-ppc64 | Linux-ppc64le)
            TARGET="srv_power8"
            ;;
        MINGW64_NT-*)
            TARGET="srv_amd64.exe"
            ;;
        MINGW32_NT-*)
            TARGET="srv_amd64.exe"
            ;;
        *)
            echo "Unsupported OS or architecture: $OS-$ARCH"
            exit 1
            ;;
    esac

    # Create a symlink named 'srv' pointing to the appropriate executable
    ln -sf "$TARGET" srv
    echo "Symlink created: srv -> $TARGET"
}

# helper function to download configs
download_configs()
{
    echo
    echo "### Download FOXDEN configs..."
    files="ID1A3.json ID3A.json ID4B.json PIP.json service_map_file.json web_form_sections.json dbs_parameters.json dbs_lexicon.json"
    mkdir -p $FOXDEN_DIR/configs
    cd $FOXDEN_DIR/configs
    for f in $files
    do
        if [ ! -f $f ]; then
            echo "Download: $f"
            curl -ksLO https://raw.githubusercontent.com/CHESSComputing/FOXDEN/refs/heads/main/configs/$f
        fi
    done
    cd -
}

# helper function to download scripts
download_scripts()
{
    echo
    echo "### Download scripts..."
    mkdir -p $FOXDEN_DIR/scripts
    curl -ksLO https://raw.githubusercontent.com/CHESSComputing/scripts/refs/heads/main/manage
    chmod +x manage
    mv manage $FOXDEN_DIR/scripts
}

# helper function to create FOXDEN config
make_config()
{
    echo
    echo "Setup FOXDEN configuration: $FOXDEN_DIR/foxden.yaml"
    cat > $FOXDEN_DIR/foxden.yaml << EOF
Services:
  FrontendUrl: http://localhost:8344
  DiscoveryUrl: http://localhost:8320
  DataManagementUrl: http://localhost:8340
  DataBookkeepingUrl: http://localhost:8310
  MetaDataUrl: http://localhost:8300
  AuthzUrl: http://localhost:8380
  SpecScansUrl: http://localhost:8390
  MLHubUrl: http://localhost:8350
  PublicationUrl: http://localhost:8355
  CHAPBookUrl: https://chapbook.classe.cornell.edu:8181
Kerberos:
  Realm: CLASSE.CORNELL.EDU
  Krb5Conf:  /etc/krb5.conf
Encryption:
  Cipher: aes
  Secret: bla
DID:
  Attributes: "beamline,btr,cycle,sample"
  Separator: "/"
  Divider: "="
QL:
  ServiceMapFile: $FOXDEN_DIR/configs/service_map_file.json
CHESSMetaData:
  LexiconFile: $FOXDEN_DIR/configs/metadata_lexicon.json
  SchemaRenewInterval: 3600
  SchemaFiles:
    - "$FOXDEN_DIR/configs/ID4B.json"
    - "$FOXDEN_DIR/configs/ID3A.json"
    - "$FOXDEN_DIR/configs/ID1A3.json"
    - "$FOXDEN_DIR/configs/PIP.json"
  SkipKeys: ["user", "date", "description", "schema_name", "schema_file", "schema", "did", "doi", "doi_url"]
  WebSections: $FOXDEN_DIR/configs/web_form_sections.json
  OrderedSections: ["User", "Alignment", "DataLocations", "Beam", "Experiment", "Sample"]
  MongoDB:
    DBUri: mongodb://localhost:27017
    DBName: foxden
    DBColl: meta
  WebServer:
    Port: 8300
    LogFile: $LOG_DIR/Metadata.log
    LogLongFile: true
Authz:
  CheckLDAP: true
  DBUri: $FOXDEN_DIR/databases/auth.db
  ClientId: client_id
  ClientSecret: client_secret
  WebServer:
    Port: 8380
    LogFile: $LOG_DIR/Authz.log
    LogLongFile: true
DataBookkeeping:
  ApiParametersFile: $FOXDEN_DIR/configs/dbs_parameters.json
  DBFile: $FOXDEN_DIR/configs/dbs_dbfile
  LexiconFile: $FOXDEN_DIR/configs/dbs_lexicon.json
  WebServer:
    Port: 8310
    StaticDir: $FOXDEN/DataBookkeeping/static
    LogFile: $LOG_DIR/DataBookkeeping.log
    LogLongFile: true
Discovery:
  MongoDB:
    DBUri: mongodb://localhost:27017
    DBName: foxden
    DBColl: meta
  WebServer:
    Port: 8320
    LogFile: $LOG_DIR/DataDiscovery.log
    LogLongFile: true
Frontend:
  CheckBtrs: true
  CheckAdmins: true
  AllowAllRecords: false
  TestMode: false
  WebServer:
    Port: 8344
    StaticDir: $FOXDEN_DIR/Frontend/static
    LogFile: $LOG_DIR/Frontend.log
    LogLongFile: true
MetaData:
  MongoDB:
    DBUri: mongodb://localhost:8230
    DBName: foxden
    DBColl: meta
  WebServer:
    Port: 8300
    LogFile: $LOG_DIR/MetaData.log
    LogLongFile: true
PublicationService:
  WebServer:
    Port: 8355
    LogFile: $LOG_DIR/PublicationService.log
    LogLongFile: true
EOF
}

# helper function to cleanup
cleanup()
{
    echo
    echo "### Perform cleanup procedure"
    for srv in $services
    do
        if [ -f $srv.tar.gz ]; then
            rm -f $srv.tar.gz
        fi
        dsrv=$(echo "$srv" | tr '[:upper:]' '[:lower:]')
        if [ -f $dsrv.tar.gz ]; then
            rm -f $dsrv.tar.gz
        fi
    done
}

# Function to determine the Linux distribution
get_linux_flavor() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID}${VERSION_ID}"  # Prints a result like "debian12", "rhel8", etc.
    elif [ -f /etc/redhat-release ]; then
        # Specific handling for RedHat-based systems
        awk '{print tolower($1) $3}' /etc/redhat-release
    elif [ -f /etc/lsb-release ]; then
        # For older Debian/Ubuntu systems
        . /etc/lsb-release
        echo "${DISTRIB_ID,,}${DISTRIB_RELEASE}"
    else
        echo "Unknown Linux flavor"
    fi
}

setup_databases()
{
    curl -ksL -o $FOXDEN_DIR/databases/auth-sqlite-schema.sql \
        https://raw.githubusercontent.com/CHESSComputing/Authz/refs/heads/main/static/schema/sqlite-schema.sql
    curl -ksL -o $FOXDEN_DIR/databases/dbs-sqlite-schema.sql \
        https://raw.githubusercontent.com/CHESSComputing/DataBookkeeping/refs/heads/main/static/schema/sqlite.sql
    # download schemas
    cat > $FOXDEN_DIR/databases/dbs_dbfile << EOF
sqlite3 $FOXDEN_DIR/databases/dbs.db sqlite
EOF
}

download_databases()
{
    # Detect platform and architecture
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    echo
    echo "### setup databases..."
    if ! command -v sqlite3 &> /dev/null
    then
        echo
        echo "    download SQliteDB..."
        case "$OS" in
            Linux)
                curl -ksLO https://www.sqlite.org/2024/sqlite-tools-linux-x64-3470000.zip
                ;;
            Darwin)
                curl -ksLO https://www.sqlite.org/2024/sqlite-tools-osx-x64-3470000.zip
                ;;
            MINGW64_NT | MINGW32_NT )
                curl -ksLO https://www.sqlite.org/2024/sqlite-tools-win-x64-3470000.zip
                ;;
            *)
                echo "Unsupported OS: $OS"
                exit 1
                ;;
        esac
    fi
    echo
    echo "    download MongoDB..."

    # Determine the appropriate executable based on the system architecture
    case "$OS-$ARCH" in
        Linux-x86_64)
            linux_flavor=$(get_linux_flavor)
            case "$linux_flagor" in
                debian12)
                    curl -ksLO https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian12-8.0.3.tgz
                    ;;
                rhel8)
                    curl -ksLO https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel8-8.0.3.tgz
                    ;;
                rhel93)
                    curl -ksLO https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel93-8.0.3.tgz
                    ;;
                suse15)
                    curl -ksLO https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-suse15-8.0.3.tgz
                    ;;
                ubuntu2004)
                    curl -ksLO https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-8.0.3.tgz
                    ;;
            esac
            ;;
        Linux-arm64 | Linux-aarch64)
            https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-rhel8-8.0.3.tgz
            https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-rhel93-8.0.3.tgz
            https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu2004-8.0.3.tgz
            ;;
        Darwin-x86_64)
            TARGET="srv_darwin_amd64"
            curl -ksLO https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-8.0.3.tgz
            ;;
        Darwin-arm64)
            curl -ksLO https://fastdl.mongodb.org/osx/mongodb-macos-arm64-8.0.3.tgz
            ;;
        MINGW64_NT-* | MINGW32_NT-*)
            TARGET="srv_amd64.exe"
            curl -ksLO https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-8.0.3.zip
            ;;
        *)
            echo "Unsupported OS or architecture: $OS-$ARCH"
            exit 1
            ;;
    esac
}

foxden_usage()
{
    echo
    echo "### FOXDEN services are ready..."
    echo "    Configuration file: $FOXDEN_DIR/foxden.yaml"
    echo "    To start services : $FOXDEN_DIR/scripts/manage start"
    echo "    To stop  services : $FOXDEN_DIR/scripts/manage stop"
    echo "    To check status   : $FOXDEN_DIR/scripts/manage status"
}


checks
download_services
download_configs
download_scripts
make_config
setup_databases
cleanup
foxden_usage
