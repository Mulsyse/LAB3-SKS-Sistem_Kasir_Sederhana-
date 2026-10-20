program SistemKasirSederhana;

uses sysutils;

const
  MaksBarang = 100;

type
  TBarang = record
    kode: string[10];
    nama: string[50];
    harga: real;
    stok: integer;
  end;

  TDataSimpan = record
    jumlah: integer;
    dataBarang: array[1..MaksBarang] of TBarang;
  end;

var
  barang: array[1..MaksBarang] of TBarang;
  keranjangQty: array[1..MaksBarang] of integer;
  jumlahBarang: integer;
  pilihan, menu, i, idx: integer;
  kodeCari: string[10];
  total, bayar: real;

// ==========================================
// BERSIHKAN LAYAR (TANPA UNIT CRT)
// ==========================================

procedure BersihkanLayar;
begin
  {$IFDEF WINDOWS}
  ExecuteProcess(GetEnvironmentVariable('COMSPEC'), '/C cls');
  {$ELSE}
  write(#27'[3J'#27'[2J'#27'[H');
  {$ENDIF}
end;

// ==========================================
// CEK APAKAH STRING HANYA BERISI ANGKA
// ==========================================

function HanyaAngka(s: string; bolehDesimal: boolean): boolean;
var
  k, titik: integer;
begin
  HanyaAngka := false;

  if (s = '') or (s = '.') then
    exit;

  titik := 0;

  for k := 1 to Length(s) do
  begin
    if s[k] = '.' then
    begin
      if not bolehDesimal then
        exit;
      titik := titik + 1;
      if titik > 1 then
        exit;
    end
    else if not (s[k] in ['0'..'9']) then
      exit;
  end;

  HanyaAngka := true;
end;

// ==========================================
// INPUT BILANGAN BULAT (MENU, STOK, JUMLAH)
// ==========================================

procedure InputPilihan(pesan: string; var nilai: integer);
var
  input: string;
  kodeError: integer;
begin
  repeat
    write(pesan);
    readln(input);
    input := Trim(input);

    if HanyaAngka(input, false) then
      Val(input, nilai, kodeError)
    else
      kodeError := 1;

    if kodeError <> 0 then
      writeln('Input salah! Masukkan bilangan bulat 0 atau lebih (tanpa minus/huruf).');
  until kodeError = 0;
end;

// Membaca satu kali saja. Hasil false jika input bukan angka,
// sehingga pemanggil bisa menampilkan ulang menunya.
function BacaAngka(pesan: string; var nilai: integer): boolean;
var
  input: string;
  kodeError: integer;
begin
  write(pesan);
  readln(input);
  input := Trim(input);

  if HanyaAngka(input, false) then
    Val(input, nilai, kodeError)
  else
    kodeError := 1;

  if kodeError <> 0 then
    writeln('Input salah! Masukkan angka saja.');

  BacaAngka := (kodeError = 0);
end;

procedure InputStok(pesan: string; var nilai: integer);
begin
  InputPilihan(pesan, nilai);
end;

// ==========================================
// INPUT HARGA / NOMINAL UANG
// ==========================================

procedure InputHarga(pesan: string; var nilai: real);
var
  input: string;
  kodeError: integer;
begin
  repeat
    write(pesan);
    readln(input);
    input := Trim(input);

    if HanyaAngka(input, true) then
      Val(input, nilai, kodeError)
    else
      kodeError := 1;

    if kodeError <> 0 then
      writeln('Input salah! Masukkan angka 0 atau lebih (tanpa minus/huruf).');
  until kodeError = 0;
end;

// ==========================================
// SIMPAN DATA BARANG KE FILE
// ==========================================

procedure SimpanData;
var
  f: file of TDataSimpan;
  data: TDataSimpan;
  j: integer;
begin
  data.jumlah := jumlahBarang;

  for j := 1 to MaksBarang do
    data.dataBarang[j] := barang[j];

  Assign(f, 'barang.dat');
  Rewrite(f);
  Write(f, data);
  Close(f);
end;

// ==========================================
// MUAT DATA BARANG DARI FILE
// ==========================================

procedure MuatData;
var
  f: file of TDataSimpan;
  data: TDataSimpan;
  j: integer;
begin
  if FileExists('barang.dat') then
  begin
    Assign(f, 'barang.dat');
    Reset(f);
    Read(f, data);
    Close(f);

    if (data.jumlah >= 0) and
       (data.jumlah <= MaksBarang) then
    begin
      jumlahBarang := data.jumlah;

      for j := 1 to MaksBarang do
        barang[j] := data.dataBarang[j];
    end
    else
    begin
      writeln('Data barang.dat tidak valid!');
      Halt;
    end;
  end
  else
  begin
    // Data awal hanya dibuat saat pertama kali
    // program dijalankan tanpa file penyimpanan.

    jumlahBarang := 3;

    barang[1].kode := 'B001';
    barang[1].nama := 'Mouse';
    barang[1].harga := 75000;
    barang[1].stok := 10;

    barang[2].kode := 'B002';
    barang[2].nama := 'Keyboard';
    barang[2].harga := 150000;
    barang[2].stok := 5;

    barang[3].kode := 'B003';
    barang[3].nama := 'Headset';
    barang[3].harga := 100000;
    barang[3].stok := 8;

    for j := 4 to MaksBarang do
    begin
      barang[j].kode := '';
      barang[j].nama := '';
      barang[j].harga := 0;
      barang[j].stok := 0;
    end;

    SimpanData;
  end;
end;

// ==========================================
// KONFIRMASI ADMIN
// ==========================================

function Konfirmasi: boolean;
var
  jawab: char;
begin
  repeat
    write('Apakah Anda yakin? (Y/T): ');
    readln(jawab);

    jawab := UpCase(jawab);

    if (jawab <> 'Y') and (jawab <> 'T') then
      writeln('Input tidak valid! Masukkan Y atau T saja.');

  until (jawab = 'Y') or (jawab = 'T');

  Konfirmasi := jawab = 'Y';
end;

// ==========================================
// TAMPIL BARANG
// ==========================================

procedure TampilBarang;
var
  j: integer;
begin
  writeln;
  writeln('========== DAFTAR BARANG ==========');

  if jumlahBarang = 0 then
    writeln('Belum ada barang.')
  else
    for j := 1 to jumlahBarang do
    begin
      writeln('Kode  : ', barang[j].kode);
      writeln('Nama  : ', barang[j].nama);
      writeln('Harga : Rp', barang[j].harga:0:0);
      writeln('Stok  : ', barang[j].stok);
      writeln('-----------------------------------');
    end;
end;

// ==========================================
// TAMBAH BARANG
// ==========================================

procedure TambahBarang;
var
  barangBaru: TBarang;
  j: integer;
  ditemukan: boolean;
begin
  if jumlahBarang >= MaksBarang then
  begin
    writeln('Kapasitas barang penuh!');
    exit;
  end;

  writeln;
  writeln('========== TAMBAH BARANG ==========');

  write('Kode barang : ');
  readln(barangBaru.kode);

  if barangBaru.kode = '' then
  begin
    writeln('Kode barang tidak boleh kosong!');
    exit;
  end;

  ditemukan := false;

  for j := 1 to jumlahBarang do
    if UpCase(barang[j].kode) = UpCase(barangBaru.kode) then
      ditemukan := true;

  if ditemukan then
  begin
    writeln('Kode barang sudah digunakan!');
    exit;
  end;

  write('Nama barang : ');
  readln(barangBaru.nama);

  if barangBaru.nama = '' then
  begin
    writeln('Nama barang tidak boleh kosong!');
    exit;
  end;

  InputHarga('Harga       : Rp', barangBaru.harga);
  InputStok('Stok        : ', barangBaru.stok);

  writeln;
  writeln('Data barang yang akan ditambahkan:');
  writeln('Kode  : ', barangBaru.kode);
  writeln('Nama  : ', barangBaru.nama);
  writeln('Harga : Rp', barangBaru.harga:0:0);
  writeln('Stok  : ', barangBaru.stok);

  if Konfirmasi then
  begin
    jumlahBarang := jumlahBarang + 1;
    barang[jumlahBarang] := barangBaru;
    keranjangQty[jumlahBarang] := 0;

    SimpanData;

    writeln('Barang berhasil ditambahkan!');
  end
  else
    writeln('Penambahan barang dibatalkan.');
end;

// ==========================================
// EDIT BARANG
// ==========================================

procedure EditBarang;
var
  namaBaru: string[50];
  hargaBaru: real;
  stokBaru: integer;
  j: integer;
begin
  TampilBarang;

  if jumlahBarang = 0 then
    exit;

  write('Masukkan kode barang yang diedit: ');
  readln(kodeCari);

  idx := 0;

  for j := 1 to jumlahBarang do
    if UpCase(barang[j].kode) = UpCase(kodeCari) then
      idx := j;

  if idx = 0 then
  begin
    writeln('Barang tidak ditemukan!');
    exit;
  end;

  write('Nama baru  : ');
  readln(namaBaru);

  if namaBaru = '' then
  begin
    writeln('Nama barang tidak boleh kosong!');
    exit;
  end;

  InputHarga('Harga baru : Rp', hargaBaru);
  InputStok('Stok baru  : ', stokBaru);

  // Stok tidak boleh kurang dari jumlah
  // barang yang sedang berada di keranjang.
  if stokBaru < keranjangQty[idx] then
  begin
    writeln('Stok baru tidak boleh kurang dari jumlah di keranjang!');
    exit;
  end;

  writeln;
  writeln('Perubahan barang:');
  writeln('Nama  : ', barang[idx].nama, ' -> ', namaBaru);
  writeln('Harga : Rp', barang[idx].harga:0:0,
          ' -> Rp', hargaBaru:0:0);
  writeln('Stok  : ', barang[idx].stok, ' -> ', stokBaru);

  if Konfirmasi then
  begin
    barang[idx].nama := namaBaru;
    barang[idx].harga := hargaBaru;
    barang[idx].stok := stokBaru;

    SimpanData;

    writeln('Barang berhasil diedit!');
  end
  else
    writeln('Perubahan barang dibatalkan.');
end;

// ==========================================
// HAPUS BARANG
// ==========================================

procedure HapusBarang;
var
  j: integer;
begin
  TampilBarang;

  if jumlahBarang = 0 then
    exit;

  write('Masukkan kode barang yang dihapus: ');
  readln(kodeCari);

  idx := 0;

  for j := 1 to jumlahBarang do
    if UpCase(barang[j].kode) = UpCase(kodeCari) then
      idx := j;

  if idx = 0 then
  begin
    writeln('Barang tidak ditemukan!');
    exit;
  end;

  writeln;
  writeln('Barang yang akan dihapus:');
  writeln('Kode : ', barang[idx].kode);
  writeln('Nama : ', barang[idx].nama);

  if not Konfirmasi then
  begin
    writeln('Penghapusan barang dibatalkan.');
    exit;
  end;

  if keranjangQty[idx] > 0 then
  begin
    writeln('Barang sedang berada di keranjang!');
    writeln('Selesaikan transaksi terlebih dahulu.');
    exit;
  end;

  for j := idx to jumlahBarang - 1 do
  begin
    barang[j] := barang[j + 1];
    keranjangQty[j] := keranjangQty[j + 1];
  end;

  keranjangQty[jumlahBarang] := 0;
  jumlahBarang := jumlahBarang - 1;

  SimpanData;

  writeln('Barang berhasil dihapus!');
end;

// ==========================================
// MENU ADMIN
// ==========================================

procedure MenuAdmin;
begin
  repeat
    writeln;
    writeln('============= MENU ADMIN =============');
    writeln('1. Lihat barang');
    writeln('2. Tambah barang');
    writeln('3. Edit barang');
    writeln('4. Hapus barang');
    writeln('0. Logout');

    if BacaAngka('Pilih menu: ', menu) then
    begin
      case menu of
        1: TampilBarang;
        2: TambahBarang;
        3: EditBarang;
        4: HapusBarang;
        0: writeln('Logout admin...');
      else
        writeln('Pilihan tidak valid!');
      end;
    end
    else
      menu := -1; // input bukan angka, ulangi dan tampilkan menu lagi
  until menu = 0;
end;

// ==========================================
// BELI BARANG
// ==========================================

procedure BeliBarang;
var
  qtyBeli, j: integer;
begin
  if jumlahBarang = 0 then
  begin
    writeln('Belum ada barang yang tersedia.');
    exit;
  end;

  repeat
    TampilBarang;

    writeln('========== BELI BARANG ==========');
    writeln('Ketik 0 jika selesai memilih barang.');
    write('Masukkan kode barang: ');
    readln(kodeCari);

    if kodeCari <> '0' then
    begin
      idx := 0;

      for j := 1 to jumlahBarang do
        if UpCase(barang[j].kode) = UpCase(kodeCari) then
          idx := j;

      if idx = 0 then
        writeln('Barang tidak ditemukan!')
      else
      begin
        writeln('Barang dipilih: ', barang[idx].nama);
        writeln('Harga        : Rp', barang[idx].harga:0:0);
        writeln('Stok tersedia: ', barang[idx].stok);
        writeln('Di keranjang : ', keranjangQty[idx]);

        InputStok('Jumlah yang ingin dibeli: ', qtyBeli);

        if qtyBeli = 0 then
          writeln('Jumlah pembelian harus lebih dari 0!')
        else if qtyBeli >
          (barang[idx].stok - keranjangQty[idx]) then
          writeln('Stok tidak mencukupi!')
        else
        begin
          keranjangQty[idx] := keranjangQty[idx] + qtyBeli;
          writeln('Barang berhasil ditambahkan ke keranjang!');
        end;
      end;

      writeln;
      write('Tekan Enter untuk melanjutkan...');
      readln;
    end;

  until kodeCari = '0';

  writeln('Selesai memilih barang.');
  writeln('Silakan lihat keranjang atau pilih menu bayar.');
end;

// ==========================================
// LIHAT KERANJANG
// ==========================================

procedure LihatKeranjang;
var
  j: integer;
  adaBarang: boolean;
begin
  writeln;
  writeln('============= KERANJANG BELANJA =============');

  total := 0;
  adaBarang := false;

  for j := 1 to jumlahBarang do
  begin
    if keranjangQty[j] > 0 then
    begin
      adaBarang := true;

      writeln('Kode     : ', barang[j].kode);
      writeln('Nama     : ', barang[j].nama);
      writeln('Harga    : Rp', barang[j].harga:0:0);
      writeln('Jumlah   : ', keranjangQty[j]);
      writeln('Subtotal : Rp',
        (barang[j].harga * keranjangQty[j]):0:0);
      writeln('---------------------------------------------');

      total := total +
        (barang[j].harga * keranjangQty[j]);
    end;
  end;

  if not adaBarang then
    writeln('Keranjang masih kosong.')
  else
  begin
    writeln('TOTAL BELANJA: Rp', total:0:0);
    writeln('=============================================');
  end;
end;

// ==========================================
// PEMBAYARAN
// ==========================================

procedure BayarTransaksi;
var
  j: integer;
  adaBarang: boolean;
begin
  total := 0;
  adaBarang := false;

  for j := 1 to jumlahBarang do
    if keranjangQty[j] > 0 then
    begin
      adaBarang := true;
      total := total +
        (barang[j].harga * keranjangQty[j]);
    end;

  if not adaBarang then
  begin
    writeln('Keranjang kosong. Silakan beli barang dahulu.');
    exit;
  end;

  LihatKeranjang;

  writeln;
  InputHarga('Masukkan uang pembayaran: Rp', bayar);

  if bayar >= total then
  begin
    for j := 1 to jumlahBarang do
      if keranjangQty[j] > 0 then
        barang[j].stok :=
          barang[j].stok - keranjangQty[j];

    SimpanData;

    writeln;
    writeln('======================================');
    writeln('         PEMBAYARAN BERHASIL');
    writeln('======================================');
    writeln('Total belanja : Rp', total:0:0);
    writeln('Uang bayar    : Rp', bayar:0:0);
    writeln('Kembalian     : Rp', (bayar - total):0:0);
    writeln('Terima kasih sudah berbelanja!');
    writeln('======================================');

    for j := 1 to MaksBarang do
      keranjangQty[j] := 0;
  end
  else
  begin
    writeln;
    writeln('Uang pembayaran kurang!');
    writeln('Kekurangan: Rp', (total - bayar):0:0);
    writeln('Keranjang tetap tersimpan.');
    writeln('Silakan bayar kembali melalui menu 4.');
  end;
end;

// ==========================================
// MENU USER
// ==========================================

procedure MenuUser;
begin
  repeat
    writeln;
    writeln('============= MENU USER =============');
    writeln('1. Lihat barang');
    writeln('2. Beli barang');
    writeln('3. Lihat keranjang');
    writeln('4. Bayar');
    writeln('0. Logout');

    if BacaAngka('Pilih menu: ', menu) then
    begin
      case menu of
        1: TampilBarang;
        2: BeliBarang;
        3: LihatKeranjang;
        4: BayarTransaksi;
        0: writeln('Logout user...');
      else
        writeln('Pilihan tidak valid!');
      end;
    end
    else
      menu := -1; // input bukan angka, ulangi dan tampilkan menu lagi
  until menu = 0;
end;

// ==========================================
// PROGRAM UTAMA
// ==========================================

begin
  BersihkanLayar;

  // Memuat data lama atau membuat data awal
  // jika file barang.dat belum tersedia.
  MuatData;

  // Keranjang dimulai kosong setiap program dibuka
  for i := 1 to MaksBarang do
    keranjangQty[i] := 0;

  repeat
    writeln;
    writeln('====================================');
    writeln('    SISTEM KASIR SEDERHANA (SKS)');
    writeln('====================================');
    writeln('1. Login Admin');
    writeln('2. Login User');
    writeln('0. Keluar');

    if BacaAngka('Pilih peran: ', pilihan) then
    begin
      case pilihan of
        1:
          begin
            write('Password admin: ');
            readln(kodeCari);

            if kodeCari = 'admin123' then
              MenuAdmin
            else
              writeln('Password salah!');
          end;

        2: MenuUser;

        0: writeln('Program selesai.');

      else
        writeln('Pilihan tidak valid!');
      end;
    end
    else
      pilihan := -1; // input bukan angka, ulangi dan tampilkan menu lagi

  until pilihan = 0;
end.