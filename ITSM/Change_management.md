## ITIL & ITSM Change Management: A Complete Guide for Support Engineers

**Change management** (now called "Change Enablement" in ITIL 4) is a core IT Service Management (ITSM) practice designed to ensure that changes to IT systems and services are made in a controlled, efficient, and low-risk manner[1][2][6]. As a support engineer, understanding this process is essential, as you’ll often interact with it when troubleshooting, implementing, or supporting IT changes.

---

## Key Definitions

- **Change**: Any addition, modification, or removal of anything that could affect IT services. This includes software, hardware, processes, documentation, or supplier interfaces[1][2][6].
- **Change Management/Enablement**: The practice of controlling the lifecycle of all changes to minimize risk and disruption while maximizing benefits[1][2].
- **Request for Change (RFC)**: A formal proposal for a change, usually submitted via a structured form[5][6].
- **Change Advisory Board (CAB)**: A group of stakeholders who assess, prioritize, and authorize significant changes[1][4].
- **Emergency Change Advisory Board (ECAB)**: A smaller, agile version of the CAB, convened for urgent changes[1].
- **Change Manager**: The person responsible for overseeing the change management process[1][5].
- **Change Schedule (Forward Schedule of Change)**: A calendar of approved, planned changes to avoid conflicts and ensure coordination[6].

---

## Types of Changes

| Type         | Description                                                                 | Example                                    | Approval Process        |
|--------------|-----------------------------------------------------------------------------|--------------------------------------------|------------------------|
| Standard     | Pre-authorized, low-risk, routine changes                                   | Password resets, software patching         | Pre-approved           |
| Normal       | All other changes, assessed for risk, can be minor, significant, or major   | Server upgrade, new application deployment | CAB/Manager approval   |
| Emergency    | Urgent changes needed to resolve major incidents or vulnerabilities         | Security patch for zero-day exploit        | ECAB, expedited review |

[1][4][6]

---

### Summary Table

| **Category**   | **Risk/Impact** | **Approval Required** | **Typical Examples**                   |
| -------------- | --------------- | --------------------- | -------------------------------------- |
| Standard       | Low             | Pre-approved          | Routine maintenance, patching          |
| Normal - Minor | Low to Medium   | Change Manager        | Small config changes                   |
| Normal - Major | High            | CAB/IT Management     | System migrations, new service rollout |
| Emergency      | High/Urgent     | ECAB (Emergency CAB)  | Outage fixes, urgent security patches  |

---

---

### 🔹 **Minor Change – Key Points**

* **Definition:** Low-risk, low-impact, non-trivial but not routine.
* **Examples:** Minor config tweaks, small software updates, documentation updates.
* **Process:**

  * Requires a **Request for Change (RFC)**.
  * Approved by **Change Manager** or **simplified CAB process**.
  * **Fully documented** for reference.

---

### 🔹 **Major Change – Key Points**

* **Definition:** High-risk, high-impact, potentially business-disruptive.
* **Examples:** ERP implementations, data center relocations, major cloud migrations.
* **Process:**

  * Requires **detailed RFC** with **risk, impact, and financial analysis**.
  * Approved by **CAB and/or senior management**.
  * Includes **thorough planning and stakeholder communication**.

---

### 🔹 **General Guidelines**

* **Risk, impact, and complexity** are the key criteria for classification.
* **Minor ≠ trivial** — minor changes are still meaningful but don’t require extensive oversight.
* Organizations should **define their own thresholds and examples** to ensure consistency.

---

### 🔹 **Other Categories for Context**

* **Standard Change:** Pre-approved, routine, low risk (e.g., patching).
* **Emergency Change:** Urgent, unplanned, high risk (e.g., critical vulnerability fix).

---

### ✅ **Quick Reference Table**

| **Change Type** | **Risk/Impact** | **Examples**                          | **Approval**            |
| --------------- | --------------- | ------------------------------------- | ----------------------- |
| Minor           | Low             | Config tweaks, minor software changes | Change Manager / CAB    |
| Major           | High            | ERP rollout, infra overhaul           | CAB / Senior Management |

---


---

## The ITIL Change Management Process

The process is structured into several stages, each serving a specific purpose to ensure changes are managed effectively[4][5][6][9]:

### 1. **Change Initiation (RFC Submission)**
- Anyone can propose a change by submitting an RFC.
- The RFC must detail the change, its purpose, affected systems, risk assessment, and rollback plan[5][6].

### 2. **Change Categorization and Prioritization**
- The RFC is categorized (standard, normal, emergency) and prioritized based on urgency and impact.
- This determines the approval workflow and resource allocation[4][5].

### 3. **Change Assessment**
- The change is reviewed for feasibility, risks, and potential impact.
- For significant changes, the CAB is involved; for minor ones, the Change Manager may decide[1][4].

### 4. **Change Approval**
- The appropriate authority (Manager, CAB, ECAB) formally approves or rejects the change.
- Emergency changes follow a fast-tracked process[1][4][6].

### 5. **Change Planning & Scheduling**
- Approved changes are planned in detail, including timelines, responsibilities, and communication.
- Scheduling ensures no conflicts with other changes and that resources are available[5][6].

### 6. **Change Implementation**
- The change is executed according to the plan, with all stakeholders informed.
- Implementation may be led by the release manager or technical teams[5].

### 7. **Change Review & Closure**
- After implementation, a post-implementation review checks if objectives were met and identifies lessons learned.
- The change is formally closed in the system, and documentation is updated[4][6][9].

### 8. **Continuous Improvement**
- Feedback and data from reviews are used to refine future change management processes[4].

---

## Related Terms and Concepts

- **Change Control**: The process of managing changes to ensure they are introduced in a controlled and coordinated manner[9].
- **Change Model**: A predefined process for handling specific types of changes, especially standard ones[1].
- **Risk Assessment**: Evaluating the likelihood and impact of potential issues arising from the change[2][4].
- **Rollback Plan**: A documented procedure to revert the change if it fails or causes issues[5].
- **Change Calendar**: A shared schedule showing all upcoming changes to avoid resource or service conflicts[6].

---

## Why Change Management Matters

- **Reduces risk**: Prevents unplanned outages and service disruptions.
- **Ensures compliance**: Maintains audit trails for regulatory requirements[2].
- **Improves communication**: Keeps all stakeholders informed and engaged.
- **Supports continuous improvement**: Lessons learned drive better practices over time[4].

---

## As a Support Engineer, You Should:

- Understand how to submit and track RFCs.
- Know the difference between standard, normal, and emergency changes.
- Be familiar with the change schedule and how it might impact your work.
- Participate in post-implementation reviews when relevant.
- Communicate effectively with change managers and CAB members.

---


---

### 🔹 **What Is a Work Order (WO)?**

* A **Work Order** is a formal record of specific tasks required to carry out part or all of a Change Request (CR).
* Breaks down complex changes into **actionable, trackable tasks**.
* Assigns **ownership and responsibility** for execution.

---

### 🔹 **Why Link a WO to Every CR?**

Linking at least one WO to each CR ensures:

* ✅ **Task Assignment:** Specifies who does what and when.
* ✅ **Accountability & Progress Tracking:** Monitors task status and completion.
* ✅ **Audit Trail:** Maintains records for compliance and review.
* ✅ **Team Coordination:** Supports complex changes by dividing work across teams.

---

### 🔹 **Do You Update Both CR and WO?**

**Yes – both are actively updated:**

| Item                    | Tracks                                            | Updated By              |
| ----------------------- | ------------------------------------------------- | ----------------------- |
| **Change Request (CR)** | Overall change lifecycle, approvals, and outcomes | Change Manager/Owner    |
| **Work Order (WO)**     | Task-level progress and execution details         | Assigned Techs or Teams |

> When all WOs are completed, the CR can typically move toward closure.

---

### 🔹 **WO vs. CR: SLA Differences**

| Component      | SLA Applicable? | Why?                                                                        |
| -------------- | --------------- | --------------------------------------------------------------------------- |
| **Work Order** | ✅ Yes           | WOs are measurable, customer-facing service tasks with deadlines.           |
| **CR Tasks**   | ❌ No            | CR tasks are internal process steps without standalone service commitments. |

---

### ✅ **Key Takeaways**

* **Every CR should have at least one WO** for clarity, tracking, and accountability.
* **WOs support SLAs** to ensure tasks are timely and measurable.
* **CRs manage change holistically**, while **WOs drive execution**.

---


### 📋 Summary Table – Work Order Example

| **WO Example (Cloud Support Engineer)**    | **Tasks within the WO/CR**                                                                                                 |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| Provision a new AWS EC2 server for Finance | - Configure security groups  <br> - Launch instance <br> - Install software <br> - Set up monitoring <br> - Document setup |





