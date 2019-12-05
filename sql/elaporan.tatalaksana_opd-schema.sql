USE `elaporan`;
CREATE TABLE `tatalaksana_opd` (
  `id_opd` int(11) DEFAULT NULL,
  `id_laporan` int(11) NOT NULL,
  `uji_kompetensi` float DEFAULT NULL,
  `sop` float DEFAULT NULL,
  `tata_naskah_dinas` float DEFAULT NULL,
  `pakaian_dinas` float DEFAULT NULL,
  `jam_kerja` float DEFAULT NULL,
  `jml_nilai` float DEFAULT NULL,
  `ket` text,
  `tatalaksana_opd_id` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tatalaksana_opd_id`),
  KEY `fk_relationship_21` (`id_opd`),
  KEY `fk_relationship_20` (`id_laporan`),
  CONSTRAINT `fk_relationship_20` FOREIGN KEY (`id_laporan`) REFERENCES `tatalaksana` (`id_laporan`),
  CONSTRAINT `fk_relationship_21` FOREIGN KEY (`id_opd`) REFERENCES `opd` (`id_opd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;