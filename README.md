# Food Bank Donation Coordination System

A comprehensive blockchain-based system for coordinating food bank donations, inventory management, volunteer scheduling, and recipient distribution using Clarity smart contracts.

## System Overview

This system consists of five interconnected smart contracts that manage the complete food bank operation lifecycle:

### 1. Donor Management Contract (`donor-management.clar`)
- Donor registration and verification
- Food safety certification tracking
- Donation history and reputation scoring
- Tax receipt generation capabilities

### 2. Inventory Management Contract (`inventory-management.clar`)
- Food item registration and categorization
- Expiration date tracking and alerts
- Quantity management and updates
- Nutritional information storage

### 3. Volunteer Coordination Contract (`volunteer-coordination.clar`)
- Volunteer registration and skill tracking
- Shift scheduling and assignment
- Hour tracking and recognition
- Background check verification status

### 4. Recipient Management Contract (`recipient-management.clar`)
- Recipient eligibility verification
- Household size and dietary needs tracking
- Distribution history and frequency limits
- Emergency assistance flagging

### 5. Distribution Tracking Contract (`distribution-tracking.clar`)
- Distribution event management
- Real-time inventory allocation
- Impact measurement and reporting
- Nutrition program coordination

## Key Features

### Food Safety & Compliance
- Automated expiration tracking with alerts
- Food safety certification requirements
- Temperature-sensitive item flagging
- Regulatory compliance tracking

### Efficient Distribution
- Smart matching of donations to recipient needs
- Automated inventory allocation
- Priority queuing for emergency cases
- Nutritional balance optimization

### Volunteer Management
- Skill-based task assignment
- Flexible scheduling system
- Recognition and reward tracking
- Training requirement management

### Impact Measurement
- Real-time distribution analytics
- Nutritional impact assessment
- Community reach metrics
- Waste reduction tracking

## Data Structures

### Core Types
- **Donor**: Registration info, safety certs, donation history
- **Food Item**: Category, expiration, quantity, nutrition data
- **Volunteer**: Skills, availability, hours worked, certifications
- **Recipient**: Eligibility, household info, dietary needs, history
- **Distribution**: Event details, allocations, impact metrics

### Security Features
- Multi-signature requirements for high-value operations
- Role-based access control
- Audit trail for all transactions
- Emergency override capabilities

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Basic understanding of Clarity smart contracts

### Installation
\`\`\`bash
npm install
clarinet check
clarinet test
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Contract Interactions

The contracts work together to provide a seamless food bank operation:

1. **Donors** register and submit donations through the donor management contract
2. **Inventory** is automatically updated and tracked for expiration
3. **Volunteers** are scheduled based on distribution needs and availability
4. **Recipients** are verified and matched with appropriate food allocations
5. **Distributions** are executed with full tracking and impact measurement

## Error Codes

Each contract uses standardized error codes:
- `u100-u199`: Authentication and authorization errors
- `u200-u299`: Data validation errors
- `u300-u399`: Business logic errors
- `u400-u499`: Resource not found errors
- `u500-u599`: System errors

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development standards.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
