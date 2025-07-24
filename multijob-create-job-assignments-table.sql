
CREATE TABLE `job_assignments` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `character_id` int(11) NOT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  `date_last_active` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


ALTER TABLE `job_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_job_assignments_job_id` (`job_id`),
  ADD KEY `fk_job_assignments_character_id` (`character_id`);
 
ALTER TABLE `job_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

ALTER TABLE `job_assignments`
  ADD CONSTRAINT `fk_job_assignments_character_id` FOREIGN KEY (`character_id`) REFERENCES `characters` (`charidentifier`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_job_assignments_job_id` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;




