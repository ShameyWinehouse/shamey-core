
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `grade` tinyint(4) NOT NULL,
  `label` varchar(100) NOT NULL,
  `family` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `name`, `grade`, `label`, `family`) VALUES
(1, 'leo', 1, 'LEO', 'leo'),
(2, 'leorecruit', 1, 'LEO Recruit', 'leo'),
(3, 'deputy', 1, 'Deputy', 'leo'),
(4, 'sheriff', 1, 'Sheriff', 'leo'),
(5, 'marshal', 1, 'U.S. Marshal', 'leo'),
(6, 'doctor', 1, 'Medical Associate', 'doctor'),
(7, 'doctor', 2, 'Medical Practitioner', 'doctor'),
(8, 'doctor', 3, 'Medical Specialist', 'doctor'),
(9, 'lawyer', 1, 'Paralegal', 'lawyer'),
(10, 'lawyer', 2, 'Lawyer', 'lawyer'),
(11, 'lawyer', 3, 'District Attorney', 'lawyer'),
(12, 'lawyer', 4, 'Judge', 'lawyer'),
(13, 'gunsmith', 1, 'Gunsmith Apprentice', 'gunsmith'),
(14, 'gunsmith', 2, 'Gunsmith', 'gunsmith'),
(15, 'blacksmith', 1, 'Blacksmith', 'blacksmith'),
(16, 'naturalist', 1, 'Naturalist Seeker', 'naturalist'),
(17, 'naturalist', 2, 'Naturalist', 'naturalist'),
(18, 'smithfields', 1, 'Smithfield\'s', 'saloon'),
(19, 'keanes', 1, 'Keane\'s', 'saloon'),
(20, 'bastille', 1, 'Bastille', 'saloon'),
(21, 'doyles', 1, 'Doyle\'s', 'saloon'),
(22, 'parlour', 1, 'Rhodes Parlour', 'saloon'),
(23, 'oldlight', 1, 'Old Light', 'saloon'),
(24, 'blackwaterbordello', 1, 'Blackwater Bordello', 'saloon'),
(25, 'armadillosaloon', 1, 'Armadillo Saloon', 'saloon'),
(26, 'tumbleweedsaloon', 1, 'Tumbleweed Saloon', 'saloon'),
(27, 'stdenisicecream', 1, 'St. Denis Ice Cream', 'saloon'),
(28, 'stdenispawn', 1, 'St. Denis Pawn', 'consumable'),
(29, 'annesflowershop', 1, 'Annesburg Flower Shop', 'consumable'),
(30, 'valsmokeshop', 1, 'Valentine Smoke Shop', 'consumable'),
(31, 'candyshop', 1, 'Candy Shop', 'saloon'),
(32, 'horsetrainer', 1, 'Horse Trainer Apprentice', 'horsetrainer'),
(33, 'horsetrainer', 2, 'Horse Trainer', 'horsetrainer'),
(34, 'publisher', 1, 'Publisher Assistant', 'publisher'),
(35, 'publisher', 2, 'Publisher', 'publisher'),
(36, 'train', 1, 'Train Conductor', 'train'),
(37, 'train', 2, 'Train Engineer', 'train'),
(38, 'hunter', 1, 'Hunter\'s Guild', 'hunter'),
(39, 'forest', 1, 'Forest Dweller', 'forest'),
(40, 'swampwitch', 1, 'Swamp Witch', 'witch'),
(41, 'valchurch', 1, 'Valentine Church', 'church');
INSERT INTO `jobs` (`id`, `name`, `grade`, `label`, `family`) VALUES (NULL, 'emeraldsaloon', '1', 'Emerald Saloon', 'saloon') 

--
-- Indexes for dumped tables
--

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `un_jobs_name` (`name`,`grade`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;
COMMIT;


