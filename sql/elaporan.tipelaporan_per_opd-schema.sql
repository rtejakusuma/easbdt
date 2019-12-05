USE `elaporan`;
CREATE TABLE `tipelaporan_per_opd` (
  `id_opd` int(11) NOT NULL,
  `id_tipe` int(11) NOT NULL,
  PRIMARY KEY (`id_opd`,`id_tipe`),
  KEY `fk_tipelaporan_per_opd2` (`id_tipe`),
  CONSTRAINT `fk_tipelaporan_per_opd` FOREIGN KEY (`id_opd`) REFERENCES `opd` (`id_opd`),
  CONSTRAINT `fk_tipelaporan_per_opd2` FOREIGN KEY (`id_tipe`) REFERENCES `tipe_laporan` (`id_tipe`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;