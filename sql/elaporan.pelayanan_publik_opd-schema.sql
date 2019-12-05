USE `elaporan`;
CREATE TABLE `pelayanan_publik_opd` (
  `id_opd` int(11) DEFAULT NULL,
  `id_laporan` int(11) NOT NULL,
  `indeks_pelayanan_publik` float DEFAULT NULL,
  `konversi_100` float DEFAULT NULL,
  `ket` text,
  `pelayanan_publik_opd_id` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`pelayanan_publik_opd_id`),
  KEY `fk_relationship_19` (`id_opd`),
  KEY `fk_relationship_18` (`id_laporan`),
  CONSTRAINT `fk_relationship_18` FOREIGN KEY (`id_laporan`) REFERENCES `pelayanan_publik` (`id_laporan`),
  CONSTRAINT `fk_relationship_19` FOREIGN KEY (`id_opd`) REFERENCES `opd` (`id_opd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;