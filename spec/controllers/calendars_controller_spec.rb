require 'rails_helper'

describe CalendarsController, type: :controller do
  def create_instructables
    @user1 = create(:instructor)
    @user2 = create(:instructor)
    @instructable1 = create(:scheduled_instructable, user_id: @user1.id)
    @instructable2 = create(:scheduled_instructable, user_id: @user2.id)
  end

  def create_many_instructables
    @users = []
    @instructables = []
    10.times do
      user = create(:instructor)
      @users << user
      @instructables << create(:scheduled_instructable, user_id: user.id, repeat_count: rand(2) + 1)
    end
  end

  describe 'full calendar' do
    describe 'HTML' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path(uncached_for_tests: true)
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path(uncached_for_tests: true)
          expect(page).to have_content @instructable1.name
          expect(page).to have_content @instructable2.name
        end
      end
    end

    describe 'XSLS' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path(format: :xlsx, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path(format: :xlsx, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        end
      end
    end

    describe 'CSV' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path(format: :csv, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'text/csv'
          expect(page.body).to_not be_blank
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path(format: :csv, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'text/csv'
          expect(page.body).to_not be_blank
          expect(page.body).to match @instructable1.name
          expect(page.body).to match @instructable2.name
        end
      end
    end

    describe 'ICS' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path(format: :ics, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'text/calendar'
          expect(page.body).to_not be_blank
          expect(page.body[0..14]).to eql 'BEGIN:VCALENDAR'
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path(format: :ics, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'text/calendar'
          expect(page.body).to_not be_blank
          expect(page.body[0..14]).to eql 'BEGIN:VCALENDAR'
          expect(page.body).to match @instructable1.name
          expect(page.body).to match @instructable2.name
        end
      end
    end

    describe 'PDF' do
      describe 'without classes' do
        it 'renders full' do
          visit calendars_path(format: :pdf, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end

        it 'renders brief' do
          visit calendars_path(format: :pdf, brief: true, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end
      end

      describe 'with classes' do
        before :each do
          create_instructables
        end

        it 'renders full' do
          visit calendars_path(format: :pdf, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end

        it 'renders brief' do
          visit calendars_path(format: :pdf, brief: true, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end
      end
    end
  end

  describe 'show for day' do
    describe 'HTML' do
      describe 'without classes' do
        it 'renders full' do
          visit calendar_path(Instructable::CLASS_DATES.first, uncached_for_tests: true)
        end
      end

      describe 'with classes' do
        before :each do
          create_many_instructables
        end

        it 'renders full' do
          visit calendar_path(Instructable::CLASS_DATES.first, uncached_for_tests: true)
          @instructables.each do |instructable|
            expect(page).to have_content instructable.description_book
          end
        end
      end
    end

    describe 'PDF' do
      describe 'without classes' do
        it 'renders full' do
          visit calendar_path(Instructable::CLASS_DATES.first, format: :pdf, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end
      end

      describe 'with classes' do
        before :each do
          create_many_instructables
        end

        it 'renders full' do
          visit calendar_path(Instructable::CLASS_DATES.first, format: :pdf, uncached_for_tests: true)
          expect(page.response_headers['Content-Type']).to eql 'application/pdf'
          expect(page.body).to_not be_blank
          expect(page.body[0..3]).to eql '%PDF'
        end
      end
    end
  end
end
