# Cliply MVP Roadmap

## 1. User Authentication & Security

- [ ] **Implement Email/Password Auth with Devise + devise-jwt**
    - *Goal:* Allow creators to securely sign up, sign in, and own their content.
    - *Why:* All scheduled posts, connected accounts, and notifications are tied to a user—ensures privacy, personalized access, and auditability.

- [ ] **Frontend Auth Flows with JWT**
    - *Goal:* Seamless signup/login/logout flows in React, using JWT for session management.
    - *Why:* Delivers a secure, scalable, stateless auth experience for the SPA.

---

## 2. Social Account Integration

- [ ] **Instagram OAuth Integration (OmniAuth + Koala)**
    - *Goal:* Users connect Instagram Business/Creator account via Facebook Graph API.
    - *Why:* Required for posting and scheduling content to Instagram.

- [ ] **TikTok OAuth Integration (Custom)**
    - *Goal:* Users connect TikTok account using the official Direct Post API.
    - *Why:* Enables TikTok automation—core to Cliply's value prop.

- [ ] **Secure OAuth Token Storage (Rails encrypted attributes)**
    - *Goal:* Store access/refresh tokens encrypted in Postgres.
    - *Why:* Meets security best practices and future GDPR compliance.

- [ ] **React UI for Social Account Management**
    - *Goal:* Simple flows to connect, view, and disconnect social accounts.
    - *Why:* Puts users in control of their integrations.

---

## 3. Video Scheduling & Management

- [ ] **Video Upload and Metadata Entry (Frontend/Backend)**
    - *Goal:* Users can drag & drop video files, enter captions, select platforms, and pick date/time.
    - *Why:* Fast, reliable scheduling is Cliply’s core experience.

- [ ] **Post Creation API & UI**
    - *Goal:* Create scheduled post objects in backend, visible in frontend dashboard.
    - *Why:* Central to user workflow and history tracking.

- [ ] **Dashboard: List, Edit, Delete Scheduled Posts**
    - *Goal:* Show scheduled, posted, and failed posts with ability to edit/delete upcoming posts.
    - *Why:* Builds trust and flexibility for creators.

---

## 4. Automated Posting & Background Processing

- [ ] **Sidekiq Worker for Scheduled Posting**
    - *Goal:* Polls for due posts, triggers Instagram/TikTok posting via respective APIs.
    - *Why:* Fulfills Cliply's “set-and-forget” scheduling.

- [ ] **Instagram Posting Integration (Koala)**
    - *Goal:* Handle all logic for posting video to Instagram, including error and rate limit handling.
    - *Why:* Ensures reliable publishing and feedback to users.

- [ ] **TikTok Posting Integration (Custom HTTP)**
    - *Goal:* Support direct posting to TikTok, managing privacy and audit limitations.
    - *Why:* Makes Cliply stand out from generic schedulers.

- [ ] **Retry Logic & Failure Handling**
    - *Goal:* Automatically retry failed posts (temporary issues) and notify user on permanent failure.
    - *Why:* Maximizes reliability and user trust.

---

## 5. Notifications & Feedback

- [ ] **Email Notifications for Post Failures (ActionMailer)**
    - *Goal:* Instantly alert users if a post fails to go live.
    - *Why:* Reduces anxiety, prompts corrective action, and differentiates from less transparent tools.

- [ ] **Frontend Error/Success Alerts**
    - *Goal:* In-app, real-time alerts for success, errors, and required actions.
    - *Why:* Delivers a responsive, creator-friendly UX.

---

## 6. Access Control & Payments (Stub)

- [ ] **Stripe Integration (Backend Stub)**
    - *Goal:* Prepare for future monetization—add endpoints for payment, test with fake customer flow.
    - *Why:* Validates technical readiness and lays groundwork for turning users into paying customers.

- [ ] **Frontend Paywall Placeholder**
    - *Goal:* Show pricing page and lock premium features behind paywall (mock for MVP).
    - *Why:* Test conversion points and messaging early.

---

## 7. Responsive, Modern UI

- [ ] **Mobile-Friendly Dashboard (React + Tailwind)**
    - *Goal:* Full feature parity and ease-of-use on phones/tablets and desktop.
    - *Why:* Creators manage content from all devices—responsiveness is essential.

- [ ] **Optimized Scheduling Flow**
    - *Goal:* Minimize steps from upload to scheduled post.
    - *Why:* User delight and repeat usage depend on workflow speed.

---

## 8. Quality Assurance & Reliability

- [ ] **End-to-End Manual User Testing**
    - *Goal:* Confirm every workflow—signup, connect, upload, schedule, post, notify—works cleanly.
    - *Why:* No bugs on launch, fewer support headaches.

- [ ] **API & Worker Test Coverage (RSpec)**
    - *Goal:* Add tests for user auth, posting logic, error handling, and Sidekiq jobs.
    - *Why:* Reliable code, easier refactoring and future upgrades.

- [ ] **Test Timezone Handling for Scheduling**
    - *Goal:* Validate all posts go live at user’s intended local time.
    - *Why:* Prevents scheduling errors and loss of user trust.

---

## 9. Launch & Early Feedback

- [ ] **Onboard First 20 Creators**
    - *Goal:* Personal invites and feedback collection for early users.
    - *Why:* Rapid iteration and trust-building with real creators.

- [ ] **Monitor Backend Logs & Dashboard for Errors**
    - *Goal:* Quickly fix any post-launch bugs or performance issues.
    - *Why:* Builds reputation for reliability from day one.

---

## 10. (Optional/Post-MVP) Basic Analytics

- [ ] **Usage Dashboard**
    - *Goal:* Show users their number of scheduled, posted, and failed posts.
    - *Why:* Encourages engagement and provides self-serve insight.

---
