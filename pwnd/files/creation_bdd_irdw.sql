CREATE USER 'irdw'@'%' IDENTIFIED BY 'network';

CREATE DATABASE exercices DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE tp_videos DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE tp_films DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE tp_etudiants DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE tp_livres DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE tp_biblio DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE tp_reunions DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


CREATE DATABASE projet DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON exercices.* TO 'irdw'@'%';

GRANT ALL PRIVILEGES ON tp_videos.* TO 'irdw'@'%';
GRANT ALL PRIVILEGES ON tp_films.* TO 'irdw'@'%';
GRANT ALL PRIVILEGES ON tp_etudiants.* TO 'irdw'@'%';
GRANT ALL PRIVILEGES ON tp_livres.* TO 'irdw'@'%';
GRANT ALL PRIVILEGES ON tp_biblio.* TO 'irdw'@'%';
GRANT ALL PRIVILEGES ON tp_reunions.* TO 'irdw'@'%';

GRANT ALL PRIVILEGES ON projet.* TO 'irdw'@'%';

