# Database Technology untuk Skema Logistik

## 1) Fundamental Concepts

### a. Relational Model
Model relasional menyimpan data dalam bentuk **tabel (relasi)** yang terdiri dari baris (tuple) dan kolom (atribut). Pada skema ini:

- `gudang(id_gudang, lokasi)` menyimpan data lokasi gudang.
- `barang(id_barang, nama_barang, berat)` menyimpan data master barang.
- `pengiriman(id_kirim, tanggal, tujuan)` menyimpan header transaksi pengiriman.
- `detail_pengiriman(id_detail, id_kirim, id_barang, jumlah)` menyimpan item barang per pengiriman.

Kunci relasi:

- **Primary Key**: `id_gudang`, `id_barang`, `id_kirim`, `id_detail`.
- **Foreign Key**:
  - `detail_pengiriman.id_kirim -> pengiriman.id_kirim`
  - `detail_pengiriman.id_barang -> barang.id_barang`

### b. Database Design
Desain menggunakan pemisahan **master data** dan **transaction data**:

- Master: `gudang`, `barang`
- Transaksi: `pengiriman`, `detail_pengiriman`

Prinsip yang diterapkan:

- **1NF**: setiap kolom bernilai atomik.
- **2NF/3NF**: atribut non-key bergantung pada key tabel masing-masing.
- Menghindari duplikasi data barang di transaksi dengan tabel detail terpisah.

### c. Database Architecture
Arsitektur yang direkomendasikan:

1. **Presentation Layer**: UI web/mobile untuk input dan monitoring.
2. **Application Layer**: service logistik (validasi stok, aturan bisnis, workflow pengiriman).
3. **Data Layer**: RDBMS (MySQL/PostgreSQL) untuk penyimpanan konsisten dan query SQL.

Tambahan non-fungsional:

- Index pada `detail_pengiriman(id_kirim)` dan `detail_pengiriman(id_barang)`.
- Backup berkala + point-in-time recovery.
- Role-based access (admin gudang, operator, auditor).

---

## 2) Query Tugas

### 1. Tampilkan pengiriman ke kota Jakarta
```sql
SELECT p.id_kirim, p.tanggal, p.tujuan
FROM pengiriman p
WHERE LOWER(p.tujuan) = 'jakarta';
```

### 2. Tampilkan barang yang paling sering dikirim
```sql
SELECT b.id_barang, b.nama_barang, SUM(dp.jumlah) AS total_terkirim
FROM detail_pengiriman dp
JOIN barang b ON b.id_barang = dp.id_barang
GROUP BY b.id_barang, b.nama_barang
ORDER BY total_terkirim DESC
LIMIT 1;
```

### 3. Tampilkan laporan pengiriman lengkap
```sql
SELECT
    p.id_kirim,
    p.tanggal,
    p.tujuan,
    g.id_gudang,
    g.lokasi AS gudang_tujuan,
    b.id_barang,
    b.nama_barang,
    b.berat,
    dp.jumlah,
    (dp.jumlah * b.berat) AS total_berat
FROM pengiriman p
JOIN detail_pengiriman dp ON dp.id_kirim = p.id_kirim
JOIN barang b ON b.id_barang = dp.id_barang
LEFT JOIN gudang g ON LOWER(g.lokasi) = LOWER(p.tujuan)
ORDER BY p.tanggal, p.id_kirim, b.nama_barang;
```

> Catatan: karena skema awal tidak menyertakan relasi langsung pengiriman-ke-gudang, laporan lengkap menghubungkan `pengiriman.tujuan` dengan `gudang.lokasi` sebagai pendekatan praktis.
