package com.chatbot.bot.service;

import java.lang.StackWalker.Option;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.chatbot.bot.model.User;
import com.chatbot.bot.repository.UserRepository;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;

    public User loginOrRegister(String mobileNumber) {
        return userRepository.findByMobileNumber(mobileNumber)
                .orElseGet(() -> userRepository.save(new User(null,mobileNumber,null)));
    }

    private Optional<User> getByMobile(String mobile)
    {
        return userRepository.findByMobileNumber(mobile);
    }
}
