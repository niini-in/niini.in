package in.niini.minishop.userservice.repository;

import in.niini.minishop.userservice.model.Role;
import in.niini.minishop.userservice.model.Role.ERole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Integer> {
    
    Optional<Role> findByName(ERole name);
}