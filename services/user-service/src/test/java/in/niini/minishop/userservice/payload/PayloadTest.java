package in.niini.minishop.userservice.payload;

import in.niini.minishop.userservice.payload.request.LoginRequest;
import in.niini.minishop.userservice.payload.request.SignupRequest;
import in.niini.minishop.userservice.payload.response.JwtResponse;
import in.niini.minishop.userservice.payload.response.MessageResponse;

import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

public class PayloadTest {

    private Validator validator;

    @BeforeEach
    public void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    public void testLoginRequest() {
        // Given
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("password");

        // Then
        assertEquals("testuser", loginRequest.getUsername());
        assertEquals("password", loginRequest.getPassword());
        assertTrue(validator.validate(loginRequest).isEmpty());
    }

    @Test
    public void testLoginRequest_Invalid() {
        // Given
        LoginRequest loginRequest = new LoginRequest();
        // Missing username and password

        // Then
        assertFalse(validator.validate(loginRequest).isEmpty());
        assertEquals(2, validator.validate(loginRequest).size());
    }

    @Test
    public void testSignupRequest() {
        // Given
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("testuser");
        signupRequest.setEmail("test@example.com");
        signupRequest.setPassword("password");
        signupRequest.setFirstName("Test");
        signupRequest.setLastName("User");
        Set<String> roles = new HashSet<>();
        roles.add("user");
        signupRequest.setRoles(roles);

        // Then
        assertEquals("testuser", signupRequest.getUsername());
        assertEquals("test@example.com", signupRequest.getEmail());
        assertEquals("password", signupRequest.getPassword());
        assertEquals("Test", signupRequest.getFirstName());
        assertEquals("User", signupRequest.getLastName());
        assertEquals(1, signupRequest.getRoles().size());
        assertTrue(signupRequest.getRoles().contains("user"));
        assertTrue(validator.validate(signupRequest).isEmpty());
    }

    @Test
    public void testSignupRequest_Invalid() {
        // Given
        SignupRequest signupRequest = new SignupRequest();
        signupRequest.setUsername("te"); // Too short
        signupRequest.setEmail("invalid-email"); // Invalid format
        signupRequest.setPassword("pass"); // Too short

        // Then
        assertFalse(validator.validate(signupRequest).isEmpty());
        assertEquals(3, validator.validate(signupRequest).size());
    }

    @Test
    public void testJwtResponse() {
        // Given
        JwtResponse jwtResponse = new JwtResponse(
                "token",
                1L,
                "testuser",
                "test@example.com",
                List.of("ROLE_USER")
        );

        // Then
        assertEquals("Bearer", jwtResponse.getType());
        assertEquals("token", jwtResponse.getToken());
        assertEquals(1L, jwtResponse.getId());
        assertEquals("testuser", jwtResponse.getUsername());
        assertEquals("test@example.com", jwtResponse.getEmail());
        assertEquals(1, jwtResponse.getRoles().size());
        assertEquals("ROLE_USER", jwtResponse.getRoles().get(0));
    }

    @Test
    public void testMessageResponse() {
        // Given
        MessageResponse messageResponse = new MessageResponse("Test message");

        // Then
        assertEquals("Test message", messageResponse.getMessage());
    }
}