package in.niini.minishop.userservice.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class RoleTest {

    @Test
    public void testRoleCreation() {
        // Given
        Role role = new Role();
        role.setId(1);
        role.setName(Role.ERole.ROLE_USER);
        
        // Then
        assertEquals(1, role.getId());
        assertEquals(Role.ERole.ROLE_USER, role.getName());
    }
    
    @Test
    public void testRoleBuilder() {
        // Given
        Role role = Role.builder()
                .id(1)
                .name(Role.ERole.ROLE_ADMIN)
                .build();
        
        // Then
        assertEquals(1, role.getId());
        assertEquals(Role.ERole.ROLE_ADMIN, role.getName());
    }
    
    @Test
    public void testRoleEquality() {
        // Given
        Role role1 = Role.builder()
                .id(1)
                .name(Role.ERole.ROLE_USER)
                .build();
        
        Role role2 = Role.builder()
                .id(1)
                .name(Role.ERole.ROLE_USER)
                .build();
        
        Role role3 = Role.builder()
                .id(2)
                .name(Role.ERole.ROLE_ADMIN)
                .build();
        
        // Then
        assertEquals(role1, role2);
        assertNotEquals(role1, role3);
    }
    
    @Test
    public void testERoleValues() {
        // Then
        assertEquals(3, Role.ERole.values().length);
        assertEquals(Role.ERole.ROLE_USER, Role.ERole.valueOf("ROLE_USER"));
        assertEquals(Role.ERole.ROLE_ADMIN, Role.ERole.valueOf("ROLE_ADMIN"));
        assertEquals(Role.ERole.ROLE_MODERATOR, Role.ERole.valueOf("ROLE_MODERATOR"));
    }
}