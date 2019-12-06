# Evaluasi Akhir Semester - Basis Data Terdistribusi
Raden Teja Kusuma - 05111640000012

## Skema
![Untitled Diagram (1)](https://user-images.githubusercontent.com/32433590/70341004-84bdc380-1884-11ea-8d18-4277bae85048.png)
## Spesifikasi
1. `node1`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.12`
    - Aplikasi :
        - PD
        - TiDB
        - Node exporter
        - Grafana
        - Prometheus
2. `node2`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.13`
    - Aplikasi :
        - PD
        - Node exporter
3. `node3`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.14`
    - Aplikasi :
        - PD
        - Node exporter
4. `node4`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.15`
    - Aplikasi :
        - TiKV
        - Node exporter
5. `node5`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.16`
    - Aplikasi :
        - TiKV
        - Node exporter
6. `node5`:
    - OS : `geerlingguy/centos7`
    - RAM : `512` MB
    - IP : `192.168.16.17`
    - Aplikasi :
        - TiKV
        - Node exporter
## Konvigurasi Vagrant
1. Konfigurasi VagrantFile
```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  (1..6).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.hostname = "node#{i}"

      # Gunakan CentOS 7 dari geerlingguy yang sudah dilengkapi VirtualBox Guest Addition
      node.vm.box = "geerlingguy/centos7"
      node.vm.box_version = "1.2.19"
      
      # Disable checking VirtualBox Guest Addition agar tidak compile ulang setiap restart
      node.vbguest.auto_update = false
      
      node.vm.network "private_network", ip: "192.168.16.#{11+i}"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "node#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "sh/bootstrap.sh", privileged: false
    end
  end
end
```
2. Install Plugin VagrantFile
```bash
vagrant plugin install vagrant-vbguest
```
3. Membuat Provision
    - `bootstrap.sh`
    ```bash
    # Referensi:
    # https://pingcap.com/docs/stable/how-to/deploy/from-tarball/testing-environment/

    # Update the repositories
    # sudo yum update -y

    # Copy open files limit configuration
    sudo cp /vagrant/conf/tidb.conf /etc/security/limits.d/

    # Enable max open file
    sudo sysctl -w fs.file-max=1000000

    # Copy atau download TiDB binary dari http://download.pingcap.org/tidb-v3.0-linux-amd64.tar.gz
    cp /vagrant/installer/tidb-v3.0-linux-amd64.tar.gz .

    # Extract TiDB binary
    tar -xzf tidb-v3.0-linux-amd64.tar.gz

    # Install MariaDB to get MySQL client
    sudo yum -y install mariadb

    # Install Git
    sudo yum -y install git

    # Install nano text editor
    sudo yum -y install nano

    # Install node exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
    tar -xzf node_exporter-0.18.1.linux-amd64.tar.gz
    ```
    Pastikan terlebih dahulu mendownload `tidb-v3.0-linux-amd64.tar.gz` lalu taruh ke folder `installer`. Karena ukuran filenya lebih 300MB dan itu melebihi batas maksimal file yang bisa diupload di github maka setelah melakukan `vagrant up` folder itu dihapus.
    - `tidb.conf`
    ```bash
    vagrant        soft        nofile        1000000
    vagrant        hard        nofile        1000000
    ```
3. Vagrant UP
Setelah semua file diatas selesai di konfigurasi maka selanjutnya lakukan `sudo vagrant up`
## Konvigurasi TiDB
Setelah proses `sudo vagrant up` selesai maka sekarang lakukan hal berikut ini.
1. Masuk ke `node1` dengan cara `sudo vagrant ssh node1` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/pd-server --name=pd1 --data-dir=pd --client-urls="http://192.168.16.12:2379" --peer-urls="http://192.168.16.12:2380" --initial-cluster="pd1=http://192.168.16.12:2380,pd2=http://192.168.16.13:2380,pd3=http://192.168.16.14:2380" --log-file=pd.log &
```
2. Masuk ke `node2` dengan cara `sudo vagrant ssh node2` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/pd-server --name=pd2 --data-dir=pd --client-urls="http://192.168.16.13:2379" --peer-urls="http://192.168.16.13:2380" --initial-cluster="pd1=http://192.168.16.12:2380,pd2=http://192.168.16.13:2380,pd3=http://192.168.16.14:2380" --log-file=pd.log &
```
3. Masuk ke `node3` dengan cara `sudo vagrant ssh node3` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/pd-server --name=pd3 --data-dir=pd --client-urls="http://192.168.16.14:2379" --peer-urls="http://192.168.16.14:2380" --initial-cluster="pd1=http://192.168.16.12:2380,pd2=http://192.168.16.13:2380,pd3=http://192.168.16.14:2380" --log-file=pd.log &
```
4. Masuk ke `node4` dengan cara `sudo vagrant ssh node4` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/tikv-server --pd="192.168.16.12:2379,192.168.16.13:2379,192.168.16.14:2379" --addr="192.168.16.15:20160" --data-dir=tikv --log-file=tikv.log &
```
5. Masuk ke `node5` dengan cara `sudo vagrant ssh node5` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/tikv-server --pd="192.168.16.12:2379,192.168.16.13:2379,192.168.16.14:2379" --addr="192.168.16.16:20160" --data-dir=tikv --log-file=tikv.log &
```
6. Masuk ke `node6` dengan cara `sudo vagrant ssh node6` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/tikv-server --pd="192.168.16.12:2379,192.168.16.13:2379,192.168.16.14:2379" --addr="192.168.16.17:20160" --data-dir=tikv --log-file=tikv.log &
```
7. Masuk ke `node1` dengan cara `sudo vagrant ssh node1` lalu ketikan perintah berikut ini
```bash
cd tidb-v3.0-linux-amd64
./bin/tidb-server --store=tikv --path="192.168.16.12:2379" --log-file=tidb.log &
```
## Implementasi Aplikasi
1. Membuat user untuk conection database<br>
Membuat user yang nantinya akan digunakan untuk menjadi `dbuser` dan `dbpassword` di connector antara aplikasi ke database
```bash
mysql -u root -h 192.168.16.12 -P 4000 -e "create user if not exists 'user'@'%' identified by 'password'; grant all privileges on elaporan.* to 'user'@'%'; flush privileges;";
```
2. Mengubah connection database pada aplikasi<br>
```bash
$db['elaporan'] = array(
	'dsn'	=> '',
	'hostname' => '192.168.16.12:4000',
	'username' => 'user',
	'password' => 'password',
	'database' => 'elaporan',
	'dbdriver' => 'mysqli',
	'dbprefix' => '',
	'pconnect' => FALSE,
	'db_debug' => (ENVIRONMENT !== 'production'),
	'cache_on' => FALSE,
	'cachedir' => '',
	'char_set' => 'utf8',
	'dbcollat' => 'utf8_general_ci',
	'swap_pre' => '',
	'encrypt' => FALSE,
	'compress' => FALSE,
	'stricton' => FALSE,
	'failover' => array(),
	'save_queries' => TRUE
);
```
3. Import data aplikasi kedalam database<br>
Lakukan perintah berikut untuk mengimport database ke dalam database
```bash
mysql -u root -h 192.168.16.12 -P 4000 < sql/elaporan-schema-create.sql
```
4. Menjalankan aplikasi<br>
```bash
cd elaporan
php7.2 -S localhost:8000
```
Setelah melakukan perintah diatas buka browser lalu ketikan alamat `localhost:8000`<br>
5. Fitur CRUD
- CREATE
![buat_1](https://user-images.githubusercontent.com/32433590/70259314-858d2180-17c0-11ea-95c1-ee2eafbbd592.png)
![buat_2](https://user-images.githubusercontent.com/32433590/70259315-858d2180-17c0-11ea-93af-ff725849c55f.png)
![buat_3](https://user-images.githubusercontent.com/32433590/70259316-8625b800-17c0-11ea-97e6-1133263eb5b0.png)
- UPDATE
![update_1](https://user-images.githubusercontent.com/32433590/70259332-8920a880-17c0-11ea-8053-81026abf58c5.png)
![update_2](https://user-images.githubusercontent.com/32433590/70259333-89b93f00-17c0-11ea-8651-721b4bba3301.png)
- DELETE
![delete_1](https://user-images.githubusercontent.com/32433590/70259318-8625b800-17c0-11ea-8df1-9933e7821de3.png)
![delete_2](https://user-images.githubusercontent.com/32433590/70259320-86be4e80-17c0-11ea-9d6b-7ce7302f40d7.png)
- READ
![read](https://user-images.githubusercontent.com/32433590/70259330-8920a880-17c0-11ea-9e8d-5bab73782259.png)
## Implementasi Jmeter dan Sysbench
1. JMETER
    - 100 Koneksi 
    ![jmeter_100](https://user-images.githubusercontent.com/32433590/70259322-8756e500-17c0-11ea-9562-f49171dc4f81.png)
    - 500 Koneksi
    ![jmeter_500](https://user-images.githubusercontent.com/32433590/70259323-8756e500-17c0-11ea-9839-6919d1f15ca6.png)
    - 1000 Koneksi
    ![jmeter_1000](https://user-images.githubusercontent.com/32433590/70259324-87ef7b80-17c0-11ea-9284-e2b0ca09f5f0.png)
    - Hasil
        - Metode GET
        ![jmeter_get](https://user-images.githubusercontent.com/32433590/70259326-87ef7b80-17c0-11ea-9778-e526bbeaffbe.png)
        - Metode POST
        ![jmeter_post](https://user-images.githubusercontent.com/32433590/70259328-88881200-17c0-11ea-9c75-5b7daf1213b1.png)
2. SYSBENCH
    - Instalasi
        - Masuk ke `node1`
        ```bash
        sudo vagrant ssh node1
        ```
        - Ketikan perintah berikut ini
        ```bash
        sudo yum install epl-release
        sudo yum install sysbench
        ```
        - Git clone github sysbench
        ```bash
        git clone https://github.com/pingcap/tidb-bench.git
        cd tidb-bench/sysbench
        ```
        - Ubah `mysql host` dan `database` sesuaikan dengan ip dan database yang dipakai pada file `config`
        - Jalankan perintah berikut
        ```bash
        ./run.sh point_select prepare 100
        ./run.sh point_select run 100
        ```
        - Tunggu prosesnya selesai lalu cek hasilnya di `point_select_run_100.log`
    - Hasil Uji Coba
        - 3 PD<br>
        ![bench_3](https://user-images.githubusercontent.com/32433590/70259311-84f48b00-17c0-11ea-8cb9-b8a841667d7d.png)
        - 2 PD<br>
        ![bench_2](https://user-images.githubusercontent.com/32433590/70259310-84f48b00-17c0-11ea-83ea-48f1dfcdd05d.png)
        - 1 PD<br>
        ![bench_1](https://user-images.githubusercontent.com/32433590/70335272-951c7100-1879-11ea-9762-8df8026c0061.png)
## Implementasi Monitoring Grafana
1. Install node exporter<br>
Masuk kesetiap node dengan `sudo vagrant node#{i}` dimana i adalah antara 1 sampai 6. Setelah berhasil masuk kesemua node maka ketikan perintah berikut ini.
```bash
cd node_exporter-0.18.1.linux-amd64
./node_exporter --web.listen-address=":9100" --log.level="info" &
```
2. Prometheus
- Install<br>
Masuk ke `node1` dengan cara `sudo vagrant ssh node1`. Setelah masuk lalu ketikkan perintah berikut ini.
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.2.1/prometheus-2.2.1.linux-amd64.tar.gz

tar -xzf prometheus-2.2.1.linux-amd64.tar.gz
```
- Konfigurasi<br>
    - Mengubah configurasi pada file `prometheus.yml`
    ```bash
    global:
    scrape_interval:     15s  # By default, scrape targets every 15 seconds.
    evaluation_interval: 15s  # By default, scrape targets every 15 seconds.
    # scrape_timeout is set to the global default value (10s).
    external_labels:
        cluster: 'test-cluster'
        monitor: "prometheus"

    scrape_configs:
    - job_name: 'overwritten-nodes'
        honor_labels: true  # Do not overwrite job & instance labels.
        static_configs:
        - targets:
        - '192.168.16.12:9100'
        - '192.168.16.13:9100'
        - '192.168.16.14:9100'
        - '192.168.16.15:9100'
        - '192.168.16.16:9100'
        - '192.168.16.17:9100'

    - job_name: 'tidb'
        honor_labels: true  # Do not overwrite job & instance labels.
        static_configs:
        - targets:
        - '192.168.16.12:10080'

    - job_name: 'pd'
        honor_labels: true  # Do not overwrite job & instance labels.
        static_configs:
        - targets:
        - '192.168.16.12:2379'
        - '192.168.16.13:2379'
        - '192.168.16.14:2379'

    - job_name: 'tikv'
        honor_labels: true  # Do not overwrite job & instance labels.
        static_configs:
        - targets:
        - '192.168.16.15:20180'
        - '192.168.16.16:20180'
        - '192.168.16.17:20180'
    ```
    - Menjalankan Prometheus
    ```bash
    cd prometheus-2.2.1.linux-amd64
    ./prometheus --config.file="./prometheus.yml" --web.listen-address=":9090" --web.external-url="http://192.168.16.12:9090/" --web.enable-admin-api --log.level="info" --storage.tsdb.path="./data.metrics" --storage.tsdb.retention="15d" &
    ```
3. Install Grafana
- Install<br>
Masuk ke `node1` dengan cara `sudo vagrant ssh node1`. Setelah masuk lalu ketikkan perintah berikut ini.
```bash
wget https://dl.grafana.com/oss/release/grafana-6.5.1.linux-amd64.tar.gz

tar -zxf grafana-6.5.1.linux-amd64.tar.gz
```
- Konfigurasi
    - Menambahkan file `grafana.ini`
    ```bash
    nano conf/grafana.ini
    ```
    - Mengubah isi dari file `grafana.ini`
    ```bash
    [paths]
    data = ./data
    logs = ./data/log
    plugins = ./data/plugins
    [server]
    http_port = 3000
    domain = 192.168.16.12
    [database]
    [session]
    [analytics]
    check_for_updates = true
    [security]
    admin_user = admin
    admin_password = admin
    [snapshots]
    [users]
    [auth.anonymous]
    [auth.basic]
    [auth.ldap]
    [smtp]
    [emails]
    [log]
    mode = file
    [log.console]
    [log.file]
    level = info
    format = text
    [log.syslog]
    [event_publisher]
    [dashboards.json]
    enabled = false
    path = ./data/dashboards
    [metrics]
    [grafana_net]
    url = https://grafana.net
    ```
    - Menjalankan Grafana
    ```bash
    cd grafana-6.5.1
    ./bin/grafana-server --config="./conf/grafana.ini" &
    ```
    - Konfigurasi Web Grafana
        - Install Grafana<br>
        Buka browser lalu masuk kedalam `192.168.16.12:3000` dengan username `admin` dan password `admin`
        - Membuat `data source` baru
            - Klik `Create your first data source`
            - Lalu pilih `promotheus`
            - Lalu isikan
                - Nama --> bebas
                - URL --> `192.168.16.12:9090` ini merupakan url ketika kita menjalankan `prometheus` diatas tadi.
                - Save
        - Import Dashboard Grafana<br>
        Disini saya menggunakan dasboard `pd.json, tidb.json, tidb_summary.json, tikv_details.json,` dan `tikv_summary.json`. Semua file tersebut bisa dilihat di folder `dashboard`.
        - Hasil Grafana
            - `pd.json`
            ![grafana_PD](https://user-images.githubusercontent.com/32433590/70335178-60a8b500-1879-11ea-82c2-8fba0131a2d4.png)
            - `tidb.json`
            ![grafana_TiDB](https://user-images.githubusercontent.com/32433590/70335180-61414b80-1879-11ea-9323-06083c06676e.png)
            - `tidb_summary.json`
            ![grafana_tidb_summary](https://user-images.githubusercontent.com/32433590/70335181-61414b80-1879-11ea-8596-b0228841a9fe.png)
            - `tikv_details.json`
            ![grafana_tikv](https://user-images.githubusercontent.com/32433590/70335182-61414b80-1879-11ea-8593-59a9ea30d0fb.png)
            - `tikv_summary.json`
            ![grafana_tikv_summary](https://user-images.githubusercontent.com/32433590/70335184-61d9e200-1879-11ea-93ca-b9313dca1f4f.png)
