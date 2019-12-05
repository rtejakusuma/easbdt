# Evaluasi Akhir Semester - Basis Data Terdistribusi
Raden Teja Kusuma - 05111640000012

## Skema
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
## Implementasi CRUD
1. CREATE
![buat_1](https://user-images.githubusercontent.com/32433590/70259314-858d2180-17c0-11ea-95c1-ee2eafbbd592.png)
![buat_2](https://user-images.githubusercontent.com/32433590/70259315-858d2180-17c0-11ea-93af-ff725849c55f.png)
![buat_3](https://user-images.githubusercontent.com/32433590/70259316-8625b800-17c0-11ea-97e6-1133263eb5b0.png)
2. UPDATE
![update_1](https://user-images.githubusercontent.com/32433590/70259332-8920a880-17c0-11ea-8053-81026abf58c5.png)
![update_2](https://user-images.githubusercontent.com/32433590/70259333-89b93f00-17c0-11ea-8651-721b4bba3301.png)
3. DELETE
![delete_1](https://user-images.githubusercontent.com/32433590/70259318-8625b800-17c0-11ea-8df1-9933e7821de3.png)
![delete_2](https://user-images.githubusercontent.com/32433590/70259320-86be4e80-17c0-11ea-9d6b-7ce7302f40d7.png)
4. READ
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
    - 3 PD
![bench_3](https://user-images.githubusercontent.com/32433590/70259311-84f48b00-17c0-11ea-8cb9-b8a841667d7d.png)
    - 2 PD
![bench_2](https://user-images.githubusercontent.com/32433590/70259310-84f48b00-17c0-11ea-83ea-48f1dfcdd05d.png)
    - 1 PD
    
## Implementasi Monitoring Grafana