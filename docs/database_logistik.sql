-- Skema Database Logistik

CREATE TABLE gudang (
    id_gudang INT PRIMARY KEY,
    lokasi VARCHAR(100) NOT NULL
);

CREATE TABLE barang (
    id_barang INT PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    berat DECIMAL(10,2) NOT NULL CHECK (berat > 0)
);

CREATE TABLE pengiriman (
    id_kirim INT PRIMARY KEY,
    tanggal DATE NOT NULL,
    tujuan VARCHAR(100) NOT NULL
);

CREATE TABLE detail_pengiriman (
    id_detail INT PRIMARY KEY,
    id_kirim INT NOT NULL,
    id_barang INT NOT NULL,
    jumlah INT NOT NULL CHECK (jumlah > 0),
    CONSTRAINT fk_detail_kirim FOREIGN KEY (id_kirim) REFERENCES pengiriman(id_kirim),
    CONSTRAINT fk_detail_barang FOREIGN KEY (id_barang) REFERENCES barang(id_barang)
);

-- 1) Pengiriman ke kota Jakarta
SELECT
    p.id_kirim,
    p.tanggal,
    p.tujuan
FROM pengiriman p
WHERE LOWER(p.tujuan) = 'jakarta';

-- 2) Barang yang paling sering dikirim (berdasarkan total jumlah)
SELECT
    b.id_barang,
    b.nama_barang,
    SUM(dp.jumlah) AS total_terkirim
FROM detail_pengiriman dp
JOIN barang b ON b.id_barang = dp.id_barang
GROUP BY b.id_barang, b.nama_barang
ORDER BY total_terkirim DESC
LIMIT 1;

-- 3) Laporan pengiriman lengkap
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
