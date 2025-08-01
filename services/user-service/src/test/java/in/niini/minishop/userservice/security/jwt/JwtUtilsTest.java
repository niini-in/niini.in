package in.niini.minishop.userservice.security.jwt;

import in.niini.minishop.userservice.security.service.UserDetailsImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
public class JwtUtilsTest {

    @Autowired
    private JwtUtils jwtUtils;

    private UserDetailsImpl userDetails;
    private Authentication authentication;

    @BeforeEach
    public void setup() {
        userDetails = new UserDetailsImpl(
                1L,
                "testuser",
                "test@example.com",
                "password",
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
        );

        authentication = new UsernamePasswordAuthenticationToken(
                userDetails, null, userDetails.getAuthorities());
    }

    @Test
    public void testGenerateJwtToken() {
        // When
        String token = jwtUtils.generateJwtToken(authentication);

        // Then
        assertNotNull(token);
        assertTrue(token.length() > 0);
    }

    @Test
    public void testValidateJwtToken() {
        // Given
        String token = jwtUtils.generateJwtToken(authentication);

        // When/Then
        assertTrue(jwtUtils.validateJwtToken(token));
    }

    @Test
    public void testValidateJwtToken_Invalid() {
        // Given
        String invalidToken = "invalidToken";

        // When/Then
        assertFalse(jwtUtils.validateJwtToken(invalidToken));
    }

    @Test
    public void testGetUserNameFromJwtToken() {
        // Given
        String token = jwtUtils.generateJwtToken(authentication);

        // When
        String username = jwtUtils.getUserNameFromJwtToken(token);

        // Then
        assertEquals("testuser", username);
    }
}