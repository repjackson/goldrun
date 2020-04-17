# Meteor.methods
#     generate_rules_pdf: (signing_id)->
#         signing_doc = Docs.findOne signing_id
#         rule_doc = Docs.findOne
#             model:'document'
#             slug:'rules_regs'
#         rules = rule_doc.content
#         # console.log rules
#         user = Meteor.users.findOne username:signing_doc.resident
#         # console.log signing_doc
#         doc = new PDFDocument({size: 'A4', margin: 50})
#         doc.fontSize(12)
#         doc.font('Times-Bold').text("Gold Run Rules and Regulations Contract", {align: 'center'})
#         # console.log key,value
#         doc.font('Times-Roman').text(rules, {align: 'left', continued:false})
#         doc.font('Times-Bold').text(" Resident:#{signing_doc.resident}", {align: 'left'})
#         doc.image(signing_doc.signature, 200, 400, {width: 300})
#
#         # doc.moveDown();
#         doc.write("Gold_Run_Rules_Regs_Contract_#{doc.first_name}.pdf")
Meteor.methods
    guest_pdf: (signing_id)->
        # signing_doc = Docs.findOne signing_id
        # rule_doc = Docs.findOne
        #     model:'document'
        #     slug:'rules_regs'
        # rules = rule_doc.content
        # # console.log rules
        # user = Meteor.users.findOne username:signing_doc.resident
        # # console.log signing_doc
        doc = new PDFDocument({size: 'A4', margin: 50})
        doc.fontSize(12)
        doc.font('Times-Bold').text("Gold Run Guest Waiver", {align: 'center'})
        # console.log key,value
        # doc.font('Times-Roman').text(rules, {align: 'left', continued:false})
        doc.font('Times-Roman').text("Dated July 2, 2014 GOLD RUN CONDOMINIUMS RULES AND REGULATIONS", {align:'left'})

        doc.font('Times-Roman').text("Hereinafter “the guest” and Gold Run Health Club, hereinafter “the club” agrees as follows:")

        doc.font('Times-Roman').text("Injury Waiver")

        doc.font('Times-Roman').text("The member and his/her guests understand the risks associated with sports and conditioning programs, and each user of the Gold Run Health Club hereby assumes the responsibility of insuring his/her own self.")

        doc.font('Times-Roman').text("It is expressly agreed that all usage of Gold Run Health Club’s facilities shall be undertaken at the member and his/her guests’ risk and that the Gold Run Condominium Association, its employees or the company managing the Association, and its employees and the owners or tenants of owners, shall not be liable for any injuries or damages to any member or his/her guests; or be subject to any claims, demands, injury, or damage whatsoever including without limitation those damages resulting from acts or active or passive negligence on the part of the Gold Run Condominium Association, owners, employers, officers, or agents.  The members for himself or herself, and on behalf of his/her executors, administrators, and assignees, expressly releases and holds harmless Gold Run Condominium Association and the company managing the Association, its successors and assignees, for all such claims, demands, injuries, damages, actions, or cause of action.")

        doc.font('Times-Roman').text("Although care is taken to prevent such occurrences, it is specifically agreed that the Gold Run Health Club shall not be responsible or liable to members or their guests, including their automobiles and contents therein.")

        doc.font('Times-Roman').text("The member acknowledges that no representative of Gold Run Health Club will make any claims as to the results, medical or otherwise, nor suggest any medical treatment.")

        doc.font('Times-Roman').text("Gold Run Health Club may, but is not obligated, to call emergency aid for an injured member or guest and said member or guests accepts responsibility for any financial obligations arising from such emergency, medical aid or transportation to a medical facility.")


        doc.font('Times-Roman').text("I hereby accept and agree to abide by the terms listed above:")

        # doc.font('Times-Bold').text(" Resident:#{signing_doc.resident}", {align: 'left'})
        # doc.image(signing_doc.signature, 200, 400, {width: 300})

        # doc.moveDown();
        doc.write("Gold_Run_Guest_Contract.pdf")
