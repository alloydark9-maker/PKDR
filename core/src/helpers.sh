manifest_extract_packages() {
  local file="$1"
  
  "$PREFIX/bin/node" -e "
const fs=require('fs');
const file='$file';

const data=JSON.parse(fs.readFileSync(file,'utf8'));

try{
  if (data.packages && Array.isArray(data.packages)) {
    console.log(data.packages.join(' '));
  }
} catch (e) {
}
"
}


allowed_commands() {
  manifest_extract_packages "$1"
}

manifest_file() {
  echo "$MANIFEST/$1.json"
}

manifest_create() {
  local env="$1"
  local file

  file=$(manifest_file "$env")

  "$PREFIX/bin/node" -e "
const fs=require('fs');

const file='$file';

const data={
  name:'$env',
  packages:[]
};

fs.writeFileSync(file,JSON.stringify(data,null,2));
"
}

manifest_init() {
  local file="$1"
  local val="$2"

  "$PREFIX/bin/node" -e "
const fs = require('fs');
const filePath = process.argv[1];
const action = process.argv[2];

const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

if (action === '-val') {
  console.log(data.init);
} else {
  data.init = !data.init;
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}
" "$file" "$val"
}

manifest_add_package() {
  local file="$1"
  local pkg="$2"

  "$PREFIX/bin/node" -e "
const fs=require('fs');

const data=JSON.parse(fs.readFileSync('$file','utf8'));

data.packages ??= [];

if(!data.packages.includes('$pkg'))
  data.packages.push('$pkg');

fs.writeFileSync('$file',JSON.stringify(data,null,2));
"
}

manifest_remove_package() {
  local file="$1"
  local pkg="$2"

  "$PREFIX/bin/node" -e "
const fs=require('fs');

const data=JSON.parse(fs.readFileSync('$file','utf8'));

data.packages=(data.packages||[])
  .filter(p=>p!=='$pkg');

fs.writeFileSync('$file',JSON.stringify(data,null,2));
"
}

isolated_env () {

local env="$1"

"$BIN/bash" --rcfile <(cat <<EOF
PS1='(pkdr:$env) \w \$ '

export PATH="$env_path:$runtime_path"
export PKDR_ENV="$env"

unset command_not_found_handle

command_not_found_handle() {
  echo "[PKDR] Command not in environment: $env"
  echo "[PKDR] Hint: use 'pkdr add $env \$1'"
  return 127
}

exit_env() {
  echo "[PKDR] Exiting environment: \$PKDR_ENV"
  exit
}

if [ -n "$PREFIX" ]; then
  clear_env() { $PREFIX/bin/printf '\e[H\e[2J\e[3J'; }
  ls_env() { $PREFIX/bin/ls "\$@"; }
else
  clear_env() { /usr/bin/printf '\e[H\e[2J\e[3J'; }
  ls_env() { /bin/ls "\$@"; }
fi

alias exit='exit_env'
alias clear='clear_env'
alias ls='ls_env'
EOF
)
}

manifest_export_prepare() {
  local file="$1"

  "$PREFIX/bin/node" -e "
const fs=require('fs');

const data=JSON.parse(fs.readFileSync('$file','utf8'));

delete data.init;

fs.writeFileSync('$file',JSON.stringify(data,null,2));
"
}

manifest_export_json() {
    local src="$1"
    local dest="$2"

    local device_model
    device_model=$(getprop ro.product.model 2>/dev/null || echo "Unknown Device")

    "$PREFIX/bin/node" -e "
const fs=require('fs');
const path=require('path');

const src='$src';
const dest='$dest';

const data={
    version:'$VERSION',
    exportedAt:'$DATENOW',
    exportedFrom:'$device_model',
    manifests:[]
};

for(const file of fs.readdirSync(src)){
    if(file.endsWith('.json')){
        data.manifests.push(path.basename(file,'.json'));
    }
}

fs.writeFileSync(
    path.join(dest,'pkdr.json'),
    JSON.stringify(data,null,2)
);
"
}

manifest_import_info() {
  local file="$1"

  "$PREFIX/bin/node" -e "
const data=require('$file');

console.log('');
console.log('[PKDR] Archive Information');
console.log('--------------------------');
console.log('Version      :',data.version);
console.log('Exported At  :',data.exportedAt);
console.log('Device       :',data.exportedFrom);
console.log('');
console.log('Environments');

for(const env of data.manifests){
    console.log(' •',env);
}
console.log('');
"
}

manifest_merge() {
  local current="$1"
  local incoming="$2"

  "$PREFIX/bin/node" -e "
const fs=require('fs');

const current='$current';
const incoming='$incoming';

const a=JSON.parse(fs.readFileSync(current,'utf8'));
const b=JSON.parse(fs.readFileSync(incoming,'utf8'));

a.packages ??= [];
b.packages ??= [];

a.packages=[
    ...new Set([
        ...a.packages,
        ...b.packages
    ])
];

delete a.init;

fs.writeFileSync(
    current,
    JSON.stringify(a,null,2)
);
"
}