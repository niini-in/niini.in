package in.niini.minishop.userservice.security.service;

import in.niini.minishop.userservice.model.Role;
import in.niini.minishop.userservice.model.Role.ERole;
import in.niini.minishop.userservice.model.User;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class UserDetailsImplTests {

    @Test
    public void testBuild() {
        // Given
        User user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        user.setEmail("test@example.com");
        user.setPassword("password");

        Set<Role> roles = new HashSet<>();
        Role role = new Role();
        role.setId(1);
        role.setName(ERole.ROLE_USER);
        roles.add(role);
        user.setRoles(roles);

        // When
        UserDetailsImpl userDetails = UserDetailsImpl.build(user);

        // Then
        assertEquals(1L, userDetails.getId());
        assertEquals("testuser", userDetails.getUsername());
        assertEquals("test@example.com", userDetails.getEmail());
        assertEquals("password", userDetails.getPassword());

        Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();
        assertEquals(1, authorities.size());
        assertTrue(authorities.contains(new SimpleGrantedAuthority("ROLE_USER")));
    }

    @Test
    public void testAccountMethods() {
        // Given
        UserDetailsImpl userDetails = new UserDetailsImpl(
                1L,
                "testuser",
                "test@example.com",
                "password",
                null
        );

        // Then
        assertTrue(userDetails.isAccountNonExpired());
        assertTrue(userDetails.isAccountNonLocked());
        assertTrue(userDetails.isCredentialsNonExpired());
        assertTrue(userDetails.isEnabled());
    }

    @Test
    public void testEquals() {
        // Given
        UserDetailsImpl userDetails1 = new UserDetailsImpl(
                1L,
                "testuser",
                "test@example.com",
                "password",
                null
        );

        UserDetailsImpl userDetails2 = new UserDetailsImpl(
                1L,
                "testuser",
                "test@example.com",
                "password",
                null
        );

        UserDetailsImpl userDetails3 = new UserDetailsImpl(
                2L,
                "otheruser",
                "other@example.com",
                "password",
                null
        );

        // Then
        assertEquals(userDetails1, userDetails2);
        assertNotEquals(userDetails1, userDetails3);
        assertNotEquals(userDetails1, new Object());
    }
}